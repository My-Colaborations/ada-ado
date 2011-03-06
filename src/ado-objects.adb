-----------------------------------------------------------------------
--  ADO Objects -- Database objects
--  Copyright (C) 2009, 2010, 2011 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------

with Util.Log;
with Util.Log.Loggers;
with Ada.Strings.Unbounded.Hash;
with ADO.Sessions.Factory;
package body ADO.Objects is

   use Util.Log;

   Log : constant Loggers.Logger := Loggers.Create ("ADO.Objects");
   use type ADO.Schemas.Class_Mapping_Access;

   --  ------------------------------
   --  Compute the hash of the object key.
   --  ------------------------------
   function Hash (Key : Object_Key) return Ada.Containers.Hash_Type is
      use Ada.Containers;

      Result : Ada.Containers.Hash_Type;
   begin
      case Key.Of_Type is
         when KEY_INTEGER =>
            if Key.Id < 0 then
               Result := Hash_Type (-Key.Id);
            else
               Result := Hash_Type (Key.Id);
            end if;

         when KEY_STRING =>
            Result := Ada.Strings.Unbounded.Hash (Key.Str);

      end case;

      --  Merge with the class mapping hash so that two key values of different
      --  tables will result in a different hash.
      Result := Result xor ADO.Schemas.Hash (Key.Of_Class);
      return Result;
   end Hash;

   --  ------------------------------
   --  Compare whether the two objects pointed to by Left and Right have the same
   --  object key.  The object key is identical if the object key type, the class
   --  mapping and the key value are identical.
   --  ------------------------------
   function Equivalent_Elements (Left, Right : Object_Key)
                                 return Boolean is
      use Ada.Strings.Unbounded;
   begin
      if Left.Of_Type /= Right.Of_Type then
         return False;
      end if;
      if Left.Of_Class /= Right.Of_Class then
         return False;
      end if;
      case Left.Of_Type is
         when KEY_INTEGER =>
            return Left.Id = Right.Id;

         when KEY_STRING =>
            return Left.Str = Right.Str;

      end case;
   end Equivalent_Elements;

   --  ------------------------------
   --  Get the key value
   --  ------------------------------
   function Get_Value (Key : Object_Key) return Identifier is
   begin
      return Key.Id;
   end Get_Value;

   --  ------------------------------
   --  Get the key value
   --  ------------------------------
   function Get_Value (Key : Object_Key) return Ada.Strings.Unbounded.Unbounded_String is
   begin
      return Key.Str;
   end Get_Value;

   --  ------------------------------
   --  Set the key value
   --  ------------------------------
   procedure Set_Value (Key   : in out Object_Key;
                        Value : in Identifier) is
   begin
      case Key.Of_Type is
         when KEY_INTEGER =>
            Key.Id := Value;

         when KEY_STRING =>
            Key.Str := Ada.Strings.Unbounded.To_Unbounded_String (Identifier'Image (Value));

      end case;
   end Set_Value;

   --  ------------------------------
   --  Set the key value
   --  ------------------------------
   procedure Set_Value (Key   : in out Object_Key;
                        Value : in String) is
   begin
      case Key.Of_Type is
         when KEY_INTEGER =>
            Key.Id := Identifier'Value (Value);

         when KEY_STRING =>
            Key.Str := Ada.Strings.Unbounded.To_Unbounded_String (Value);

      end case;
   end Set_Value;

   --  ------------------------------
   --  Get the key as a string
   --  ------------------------------
   function To_String (Key : Object_Key) return String is
   begin
      case Key.Of_Type is
         when KEY_INTEGER =>
            return Identifier'Image (Key.Id);

         when KEY_STRING =>
            return Ada.Strings.Unbounded.To_String (Key.Str);

      end case;
   end To_String;

   --  ------------------------------
   --  Return the key value in a bean object.
   --  ------------------------------
   function To_Object (Key : Object_Key) return Util.Beans.Objects.Object is
   begin
      case Key.Of_Type is
         when KEY_INTEGER =>
            return Util.Beans.Objects.To_Object (Long_Long_Integer (Key.Id));

         when KEY_STRING =>
            return Util.Beans.Objects.To_Object (Key.Str);

      end case;
   end To_Object;

   --  ------------------------------
   --  Increment the reference counter when an object is copied
   --  ------------------------------
   overriding
   procedure Adjust (Object : in out Object_Ref) is
   begin
      if Object.Object /= null then
         Util.Concurrent.Counters.Increment (Object.Object.Counter);
      end if;
   end Adjust;

   --  ------------------------------
   --  Decrement the reference counter and release the object record.
   --  ------------------------------
   overriding
   procedure Finalize (Object : in out Object_Ref) is
      Is_Zero : Boolean;
   begin
      if Object.Object /= null then
         Util.Concurrent.Counters.Decrement (Object.Object.Counter, Is_Zero);
         if Is_Zero then
            Destroy (Object.Object);
            Object.Object := null;
         end if;
      end if;
   end Finalize;

   --  ------------------------------
   --  Mark the field identified by <b>Field</b> as modified.
   --  ------------------------------
   procedure Set_Field (Object : in out Object_Ref'Class;
                        Field  : in Positive) is
   begin
      if Object.Object = null then
         Object.Allocate;
         Object.Object.Is_Loaded := True;
      elsif not Object.Object.Is_Loaded then
         Object.Lazy_Load;
      end if;
      Object.Object.Modified (Field) := True;
   end Set_Field;

   --  ------------------------------
   --  Check whether this object is initialized or not.
   --  ------------------------------
   function Is_Null (Object : in Object_Ref'Class) return Boolean is
   begin
      return Object.Object = null;
   end Is_Null;

   --  ------------------------------
   --  Load the object from the database if it was not already loaded.
   --  For a lazy association, the <b>Object_Record</b> is allocated and holds the primary key.
   --  The <b>Is_Loaded</b> boolean is cleared thus indicating the other values are not loaded.
   --  This procedure makes sure these values are loaded by invoking <b>Load</b> if necessary.
   --  Raises SESSION_EXPIRED if the session associated with the object is closed.
   --  ------------------------------
   procedure Lazy_Load (Ref : in Object_Ref'Class) is
   begin
      if Ref.Object /= null and then not Ref.Object.Is_Loaded then
         if Ref.Object.Session = null then
            raise SESSION_EXPIRED;
         end if;
         if Ref.Object.Session.Session = null then
            raise SESSION_EXPIRED;
         end if;
         declare
            S : ADO.Sessions.Session
              := ADO.Sessions.Factory.Get_Session (Ref.Object.Session.Session.all'Access);
         begin
            Ref.Object.Load (S);
         end;
      end if;
   end Lazy_Load;

   --  ------------------------------
   --  Internal method to get the object record instance and make sure it is fully loaded.
   --  If the object was not yet loaded, calls <b>Lazy_Load</b> to get the values from the
   --  database.  Raises SESSION_EXPIRED if the session associated with the object is closed.
   --  ------------------------------
   function Get_Load_Object (Ref : in Object_Ref'Class) return Object_Record_Access is
   begin
      Ref.Lazy_Load;
      return Ref.Object;
   end Get_Load_Object;

   --  ------------------------------
   --  Internal method to get the object record instance.
   --  ------------------------------
   function Get_Object (Ref : in Object_Ref'Class) return Object_Record_Access is
   begin
      return Ref.Object;
   end Get_Object;

   --  ------------------------------
   --  Get the object key
   --  ------------------------------
   function Get_Key (Ref : in Object_Ref'Class) return Object_Key is
   begin
      return Ref.Object.Key;
   end Get_Key;

   --  ------------------------------
   --  Set the object key.
   --  ------------------------------
   procedure Set_Key_Value (Ref     : in out Object_Ref'Class;
                            Value   : in Identifier;
                            Session : in ADO.Sessions.Session'Class) is
   begin
      if Ref.Object = null then
         Ref.Allocate;
      end if;
      Ref.Object.Set_Key_Value (Value);
      Ref.Object.Session := Session.Get_Session_Proxy;
      Ref.Object.Is_Created := True;
   end Set_Key_Value;

   --  ------------------------------
   --  Set the object key.
   --  ------------------------------
   procedure Set_Key_Value (Ref     : in out Object_Ref'Class;
                            Value   : in Ada.Strings.Unbounded.Unbounded_String;
                            Session : in ADO.Sessions.Session'Class) is
   begin
      if Ref.Object = null then
         Ref.Allocate;
      end if;
      Ref.Object.Set_Key_Value (Value);
      Ref.Object.Session := Session.Get_Session_Proxy;
      Ref.Object.Is_Created := True;
   end Set_Key_Value;


   --  ------------------------------
   --  Check if the two objects are the same database objects.
   --  The comparison is only made on the primary key.
   --  Returns true if the two objects have the same primary key.
   --  ------------------------------
   function "=" (Left : Object_Ref; Right : Object_Ref) return Boolean is
   begin
      --  Same target object
      if Left.Object = Right.Object then
         return True;
      end if;
      --  One of the target object is null
      if Left.Object = null or Right.Object = null then
         return False;
      end if;
      return Left.Object.Key = Right.Object.Key;
   end "=";

   procedure Set_Object (Ref    : in out Object_Ref'Class;
                         Object : in Object_Record_Access) is
      Is_Zero : Boolean;
   begin
      if Ref.Object /= null and Ref.Object /= Object then
         Util.Concurrent.Counters.Decrement (Ref.Object.Counter, Is_Zero);
         if Is_Zero then
            Destroy (Ref.Object);
         end if;
      end if;
      Ref.Object := Object;
   end Set_Object;

   procedure Set_Object (Ref     : in out Object_Ref'Class;
                         Object  : in Object_Record_Access;
                         Session : in ADO.Sessions.Session'Class) is
   begin
      if Object /= null and then Object.Session = null then
         Object.Session := Session.Get_Session_Proxy;
      end if;
      Ref.Set_Object (Object);
   end Set_Object;

   --  ------------------------------
   --  Get the object key
   --  ------------------------------
   function Get_Key (Ref : in Object_Record'Class) return Object_Key is
   begin
      return Ref.Key;
   end Get_Key;

   --  ------------------------------
   --  Set the object key
   --  ------------------------------
   procedure Set_Key (Ref : in out Object_Record'Class;
                      Key : in Object_Key) is
   begin
      Ref.Key := Key;
   end Set_Key;

   --  ------------------------------
   --  Get the object key value as an identifier
   --  ------------------------------
   function Get_Key_Value (Ref : in Object_Record'Class)
                           return Identifier is
   begin
      return Ref.Key.Id;
   end Get_Key_Value;

   function Get_Key_Value (Ref : in Object_Record'Class) return Ada.Strings.Unbounded.Unbounded_String is
   begin
      return Ref.Key.Str;
   end Get_Key_Value;

   procedure Set_Key_Value (Ref   : in out Object_Record'Class;
                            Value : in Identifier) is
   begin
      Set_Value (Ref.Key, Value);
   end Set_Key_Value;

   procedure Set_Key_Value (Ref   : in out Object_Record'Class;
                            Value : in Ada.Strings.Unbounded.Unbounded_String) is
   begin
      Ref.Key.Str    := Value;
   end Set_Key_Value;

   --  ------------------------------
   --  Get the table name associated with the object record.
   --  ------------------------------
   function Get_Table_Name (Ref : in Object_Record'Class) return Util.Strings.Name_Access is
   begin
      if Ref.Key.Of_Class = null then
         return null;
      else
         return Ref.Key.Of_Class.Table;
      end if;
   end Get_Table_Name;

   --  ------------------------------
   --  Check if this is a new object.
   --  Returns True if an insert is necessary to persist this object.
   --  ------------------------------
   function Is_Created (Ref : in Object_Record'Class) return Boolean is
   begin
      return Ref.Is_Created;
   end Is_Created;

   --  ------------------------------
   --  Mark the object as created in the database.
   --  ------------------------------
   procedure Set_Created (Ref : in out Object_Record'Class) is
   begin
      Ref.Is_Created := True;
      Ref.Is_Loaded  := True;
      Ref.Modified := (others => False);
   end Set_Created;

   --  ------------------------------
   --  Check if the field at position <b>Field</b> was modified.
   --  ------------------------------
   function Is_Modified (Ref   : in Object_Record'Class;
                         Field : in Positive) return Boolean is
   begin
      return Ref.Modified (Field);
   end Is_Modified;

   --  ------------------------------
   --  Clear the modification flag associated with the field at
   --  position <b>Field</b>.
   --  ------------------------------
   procedure Clear_Modified (Ref   : in out Object_Record'Class;
                             Field : in Positive) is
   begin
      Ref.Modified (Field) := False;
   end Clear_Modified;

   --  ------------------------------
   --  Copy the source object record into the target.
   --  ------------------------------
   procedure Copy (To   : in out Object_Record;
                   From : in Object_Record'Class) is
   begin
      To.Session    := From.Session;
      To.Is_Created := From.Is_Created;
      To.Is_Loaded  := From.Is_Loaded;
      To.Modified   := From.Modified;
      To.Key        := From.Key;
   end Copy;

   function Create_Session_Proxy (S : access ADO.Sessions.Session_Record)
                                  return Session_Proxy_Access is
      Result : constant Session_Proxy_Access := new Session_Proxy;
   begin
      Result.Session := S;
      return Result;
   end Create_Session_Proxy;

end ADO.Objects;
