-----------------------------------------------------------------------
--  Regtests.Simple.Model -- Regtests.Simple.Model
-----------------------------------------------------------------------
--  File generated by ada-gen DO NOT MODIFY
--  Template used: templates/model/package-body.xhtml
--  Ada Generator: https://ada-gen.googlecode.com/svn/trunk Revision 166
-----------------------------------------------------------------------
-----------------------------------------------------------------------
with Ada.Unchecked_Deallocation;
package body Regtests.Simple.Model is

   use type ADO.Objects.Object_Record_Access;
   use type ADO.Objects.Object_Ref;
   use type ADO.Objects.Object_Record;

   function User_Key (Id : in ADO.Identifier) return ADO.Objects.Object_Key is
      Result : ADO.Objects.Object_Key (Of_Type  => ADO.Objects.KEY_STRING,
                                       Of_Class => USER_TABLE'Access);
   begin
      ADO.Objects.Set_Value (Result, Id);
      return Result;
   end User_Key;
   function User_Key (Id : in String) return ADO.Objects.Object_Key is
      Result : ADO.Objects.Object_Key (Of_Type  => ADO.Objects.KEY_STRING,
                                       Of_Class => USER_TABLE'Access);
   begin
      ADO.Objects.Set_Value (Result, Id);
      return Result;
   end User_Key;
   function "=" (Left, Right : User_Ref'Class) return Boolean is
   begin
      return ADO.Objects.Object_Ref'Class (Left) = ADO.Objects.Object_Ref'Class (Right);
   end "=";
   procedure Set_Field (Object : in out User_Ref'Class;
                        Impl   : out User_Access;
                        Field  : in Positive) is
   begin
      Object.Set_Field (Field);
      Impl := User_Impl (Object.Get_Object.all)'Access;
   end Set_Field;
   --  Internal method to allocate the Object_Record instance
   procedure Allocate (Object : in out User_Ref) is
      Impl : User_Access;
   begin
      Impl := new User_Impl;
      Impl.Version := 0;
      Impl.Value := ADO.NO_IDENTIFIER;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Allocate;

   -- ----------------------------------------
   --  Data object: User
   -- ----------------------------------------
   procedure Set_Id (Object : in out User_Ref;
                      Value  : in ADO.Identifier) is
      Impl : User_Access;
   begin
      Set_Field (Object, Impl, 1);
      ADO.Objects.Set_Key_Value (Impl.all, Value);
   end Set_Id;
   function Get_Id (Object : in User_Ref)
                  return ADO.Identifier is
      Impl : constant User_Access := User_Impl (Object.Get_Object.all)'Access;
   begin
      return Impl.Get_Key_Value;
   end Get_Id;
   function Get_Version (Object : in User_Ref)
                  return Integer is
      Impl : constant User_Access := User_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Version;
   end Get_Version;
   procedure Set_Value (Object : in out User_Ref;
                         Value  : in ADO.Identifier) is
      Impl : User_Access;
   begin
      Set_Field (Object, Impl, 3);
      Impl.Value := Value;
   end Set_Value;
   function Get_Value (Object : in User_Ref)
                  return ADO.Identifier is
      Impl : constant User_Access := User_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Value;
   end Get_Value;
   procedure Set_Name (Object : in out User_Ref;
                        Value : in String) is
   begin
      Object.Set_Name (Ada.Strings.Unbounded.To_Unbounded_String (Value));
   end Set_Name;
   procedure Set_Name (Object : in out User_Ref;
                        Value  : in Ada.Strings.Unbounded.Unbounded_String) is
      Impl : User_Access;
   begin
      Set_Field (Object, Impl, 4);
      Impl.Name := Value;
   end Set_Name;
   function Get_Name (Object : in User_Ref)
                 return String is
   begin
      return Ada.Strings.Unbounded.To_String (Object.Get_Name);
   end Get_Name;
   function Get_Name (Object : in User_Ref)
                  return Ada.Strings.Unbounded.Unbounded_String is
      Impl : constant User_Access := User_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Name;
   end Get_Name;
   --  Copy of the object.
   function Copy (Object : User_Ref) return User_Ref is
      Result : User_Ref;
   begin
      if not Object.Is_Null then
         declare
            Impl : constant User_Access
              := User_Impl (Object.Get_Load_Object.all)'Access;
            Copy : constant User_Access
              := new User_Impl;
         begin
            ADO.Objects.Set_Object (Result, Copy.all'Access);
            Copy.Copy (Impl.all);
            Copy.Version := Impl.Version;
            Copy.Value := Impl.Value;
            Copy.Name := Impl.Name;
         end;
      end if;
      return Result;
   end Copy;
   procedure Find (Object  : in out User_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Impl  : constant User_Access := new User_Impl;
   begin
      Impl.Find (Session, Query, Found);
      if Found then
         ADO.Objects.Set_Object (Object, Impl.all'Access);
      else
         ADO.Objects.Set_Object (Object, null);
         Destroy (Impl);
      end if;
   end Find;
   procedure Load (Object  : in out User_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Id      : in ADO.Identifier) is
      Impl  : constant User_Access := new User_Impl;
      Found : Boolean;
      Query : ADO.SQL.Query;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("id = ?");
      Impl.Find (Session, Query, Found);
      if not Found then
         Destroy (Impl);
         raise ADO.Objects.NOT_FOUND;
      end if;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Load;
   procedure Load (Object  : in out User_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Id      : in ADO.Identifier;
                   Found   : out Boolean) is
      Impl  : constant User_Access := new User_Impl;
      Query : ADO.SQL.Query;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("id = ?");
      Impl.Find (Session, Query, Found);
      if not Found then
         Destroy (Impl);
      else
         ADO.Objects.Set_Object (Object, Impl.all'Access);
      end if;
   end Load;
   procedure Save (Object  : in out User_Ref;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl = null then
         Impl := new User_Impl;
         ADO.Objects.Set_Object (Object, Impl);
      end if;
      if not ADO.Objects.Is_Created (Impl.all) then
         Impl.Create (Session);
      else
         Impl.Save (Session);
      end if;
   end Save;
   procedure Delete (Object  : in out User_Ref;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : constant ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl /= null then
         Impl.Delete (Session);
      end if;
   end Delete;
   --  --------------------
   --  Free the object
   --  --------------------
   procedure Destroy (Object : access User_Impl) is
      type User_Impl_Ptr is access all User_Impl;
      procedure Unchecked_Free is new Ada.Unchecked_Deallocation
              (User_Impl, User_Impl_Ptr);
      Ptr : User_Impl_Ptr := User_Impl (Object.all)'Access;
   begin
      Unchecked_Free (Ptr);
   end Destroy;
   procedure Find (Object  : in out User_Impl;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Stmt : ADO.Statements.Query_Statement
          := Session.Create_Statement (USER_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      if Stmt.Has_Elements then
         Object.Load (Stmt, Session);
         Stmt.Next;
         Found := not Stmt.Has_Elements;
      else
         Found := False;
      end if;
   end Find;
   overriding
   procedure Load (Object  : in out User_Impl;
                   Session : in out ADO.Sessions.Session'Class) is
      Found : Boolean;
      Query : ADO.SQL.Query;
      Id    : constant ADO.Identifier := Object.Get_Key_Value;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("id = ?");
      Object.Find (Session, Query, Found);
      if not Found then
         raise ADO.Objects.NOT_FOUND;
      end if;
   end Load;
   procedure Save (Object  : in out User_Impl;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Update_Statement
         := Session.Create_Statement (USER_TABLE'Access);
   begin
      if Object.Is_Modified (1) then
         Stmt.Save_Field (Name  => COL_0_1_NAME, --  ID
                          Value => Object.Get_Key);
         Object.Clear_Modified (1);
      end if;
      if Object.Is_Modified (3) then
         Stmt.Save_Field (Name  => COL_2_1_NAME, --  VALUE
                          Value => Object.Value);
         Object.Clear_Modified (3);
      end if;
      if Object.Is_Modified (4) then
         Stmt.Save_Field (Name  => COL_3_1_NAME, --  NAME
                          Value => Object.Name);
         Object.Clear_Modified (4);
      end if;
      if Stmt.Has_Save_Fields then
         Object.Version := Object.Version + 1;
         Stmt.Save_Field (Name  => "version",
                          Value => Object.Version);
         Stmt.Set_Filter (Filter => "id = ? and version = ?");
         Stmt.Add_Param (Value => Object.Get_Key);
         Stmt.Add_Param (Value => Object.Version - 1);
         declare
            Result : Integer;
         begin
            Stmt.Execute (Result);
            if Result /= 1 then
               if Result = 0 then
                  raise ADO.Objects.LAZY_LOCK;
               else
                  raise ADO.Objects.UPDATE_ERROR;
               end if;
            end if;
         end;
      end if;
   end Save;
   procedure Create (Object  : in out User_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Query : ADO.Statements.Insert_Statement
                  := Session.Create_Statement (USER_TABLE'Access);
      Result : Integer;
   begin
      Object.Version := 1;
      Session.Allocate (Id => Object);
      Query.Save_Field (Name  => COL_0_1_NAME, --  ID
                        Value => Object.Get_Key);
      Query.Save_Field (Name  => COL_1_1_NAME, --  object_version
                        Value => Object.Version);
      Query.Save_Field (Name  => COL_2_1_NAME, --  VALUE
                        Value => Object.Value);
      Query.Save_Field (Name  => COL_3_1_NAME, --  NAME
                        Value => Object.Name);
      Query.Execute (Result);
      if Result /= 1 then
         raise ADO.Objects.INSERT_ERROR;
      end if;
      ADO.Objects.Set_Created (Object);
   end Create;
   procedure Delete (Object  : in out User_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Delete_Statement
         := Session.Create_Statement (USER_TABLE'Access);
   begin
      Stmt.Set_Filter (Filter => "id = ?");
      Stmt.Add_Param (Value => Object.Get_Key);
      Stmt.Execute;
   end Delete;
   function Get_Value (Item : in User_Ref;
                       Name : in String) return Util.Beans.Objects.Object is
      Impl : constant access User_Impl
         := User_Impl (Item.Get_Load_Object.all)'Access;
   begin
      if Name = "id" then
         return ADO.Objects.To_Object (Impl.Get_Key);
      end if;
      if Name = "value" then
         return Util.Beans.Objects.To_Object (Long_Long_Integer (Impl.Value));
      end if;
      if Name = "name" then
         return Util.Beans.Objects.To_Object (Impl.Name);
      end if;
      raise ADO.Objects.NOT_FOUND;
   end Get_Value;
   procedure List (Object  : in out User_Vector;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class) is
      Stmt : ADO.Statements.Query_Statement := Session.Create_Statement (USER_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      User_Vectors.Clear (Object);
      while Stmt.Has_Elements loop
         declare
            Item : User_Ref;
            Impl : constant User_Access := new User_Impl;
         begin
            Impl.Load (Stmt, Session);
            ADO.Objects.Set_Object (Item, Impl.all'Access);
            Object.Append (Item);
         end;
         Stmt.Next;
      end loop;
   end List;
   --  ------------------------------
   --  Load the object from current iterator position
   --  ------------------------------
   procedure Load (Object  : in out User_Impl;
                   Stmt    : in out ADO.Statements.Query_Statement'Class;
                   Session : in out ADO.Sessions.Session'Class) is
      pragma Unreferenced (Session);
   begin
      Object.Set_Key_Value (Stmt.Get_Identifier (0));
      Object.Value := Stmt.Get_Identifier (2);
      Object.Name := Stmt.Get_Unbounded_String (3);
      Object.Version := Stmt.Get_Integer (1);
      ADO.Objects.Set_Created (Object);
   end Load;
   function Allocate_Key (Id : in ADO.Identifier) return ADO.Objects.Object_Key is
      Result : ADO.Objects.Object_Key (Of_Type  => ADO.Objects.KEY_STRING,
                                       Of_Class => ALLOCATE_TABLE'Access);
   begin
      ADO.Objects.Set_Value (Result, Id);
      return Result;
   end Allocate_Key;
   function Allocate_Key (Id : in String) return ADO.Objects.Object_Key is
      Result : ADO.Objects.Object_Key (Of_Type  => ADO.Objects.KEY_STRING,
                                       Of_Class => ALLOCATE_TABLE'Access);
   begin
      ADO.Objects.Set_Value (Result, Id);
      return Result;
   end Allocate_Key;
   function "=" (Left, Right : Allocate_Ref'Class) return Boolean is
   begin
      return ADO.Objects.Object_Ref'Class (Left) = ADO.Objects.Object_Ref'Class (Right);
   end "=";
   procedure Set_Field (Object : in out Allocate_Ref'Class;
                        Impl   : out Allocate_Access;
                        Field  : in Positive) is
   begin
      Object.Set_Field (Field);
      Impl := Allocate_Impl (Object.Get_Object.all)'Access;
   end Set_Field;
   --  Internal method to allocate the Object_Record instance
   procedure Allocate (Object : in out Allocate_Ref) is
      Impl : Allocate_Access;
   begin
      Impl := new Allocate_Impl;
      Impl.Object_Version := 0;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Allocate;

   -- ----------------------------------------
   --  Data object: Allocate
   -- ----------------------------------------
   procedure Set_Id (Object : in out Allocate_Ref;
                      Value  : in ADO.Identifier) is
      Impl : Allocate_Access;
   begin
      Set_Field (Object, Impl, 1);
      ADO.Objects.Set_Key_Value (Impl.all, Value);
   end Set_Id;
   function Get_Id (Object : in Allocate_Ref)
                  return ADO.Identifier is
      Impl : constant Allocate_Access := Allocate_Impl (Object.Get_Object.all)'Access;
   begin
      return Impl.Get_Key_Value;
   end Get_Id;
   function Get_Object_Version (Object : in Allocate_Ref)
                  return Integer is
      Impl : constant Allocate_Access := Allocate_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Object_Version;
   end Get_Object_Version;
   procedure Set_Name (Object : in out Allocate_Ref;
                        Value : in String) is
   begin
      Object.Set_Name (Ada.Strings.Unbounded.To_Unbounded_String (Value));
   end Set_Name;
   procedure Set_Name (Object : in out Allocate_Ref;
                        Value  : in Ada.Strings.Unbounded.Unbounded_String) is
      Impl : Allocate_Access;
   begin
      Set_Field (Object, Impl, 3);
      Impl.Name := Value;
   end Set_Name;
   function Get_Name (Object : in Allocate_Ref)
                 return String is
   begin
      return Ada.Strings.Unbounded.To_String (Object.Get_Name);
   end Get_Name;
   function Get_Name (Object : in Allocate_Ref)
                  return Ada.Strings.Unbounded.Unbounded_String is
      Impl : constant Allocate_Access := Allocate_Impl (Object.Get_Load_Object.all)'Access;
   begin
      return Impl.Name;
   end Get_Name;
   --  Copy of the object.
   function Copy (Object : Allocate_Ref) return Allocate_Ref is
      Result : Allocate_Ref;
   begin
      if not Object.Is_Null then
         declare
            Impl : constant Allocate_Access
              := Allocate_Impl (Object.Get_Load_Object.all)'Access;
            Copy : constant Allocate_Access
              := new Allocate_Impl;
         begin
            ADO.Objects.Set_Object (Result, Copy.all'Access);
            Copy.Copy (Impl.all);
            Copy.Object_Version := Impl.Object_Version;
            Copy.Name := Impl.Name;
         end;
      end if;
      return Result;
   end Copy;
   procedure Find (Object  : in out Allocate_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Impl  : constant Allocate_Access := new Allocate_Impl;
   begin
      Impl.Find (Session, Query, Found);
      if Found then
         ADO.Objects.Set_Object (Object, Impl.all'Access);
      else
         ADO.Objects.Set_Object (Object, null);
         Destroy (Impl);
      end if;
   end Find;
   procedure Load (Object  : in out Allocate_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Id      : in ADO.Identifier) is
      Impl  : constant Allocate_Access := new Allocate_Impl;
      Found : Boolean;
      Query : ADO.SQL.Query;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("id = ?");
      Impl.Find (Session, Query, Found);
      if not Found then
         Destroy (Impl);
         raise ADO.Objects.NOT_FOUND;
      end if;
      ADO.Objects.Set_Object (Object, Impl.all'Access);
   end Load;
   procedure Load (Object  : in out Allocate_Ref;
                   Session : in out ADO.Sessions.Session'Class;
                   Id      : in ADO.Identifier;
                   Found   : out Boolean) is
      Impl  : constant Allocate_Access := new Allocate_Impl;
      Query : ADO.SQL.Query;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("id = ?");
      Impl.Find (Session, Query, Found);
      if not Found then
         Destroy (Impl);
      else
         ADO.Objects.Set_Object (Object, Impl.all'Access);
      end if;
   end Load;
   procedure Save (Object  : in out Allocate_Ref;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl = null then
         Impl := new Allocate_Impl;
         ADO.Objects.Set_Object (Object, Impl);
      end if;
      if not ADO.Objects.Is_Created (Impl.all) then
         Impl.Create (Session);
      else
         Impl.Save (Session);
      end if;
   end Save;
   procedure Delete (Object  : in out Allocate_Ref;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Impl : constant ADO.Objects.Object_Record_Access := Object.Get_Object;
   begin
      if Impl /= null then
         Impl.Delete (Session);
      end if;
   end Delete;
   --  --------------------
   --  Free the object
   --  --------------------
   procedure Destroy (Object : access Allocate_Impl) is
      type Allocate_Impl_Ptr is access all Allocate_Impl;
      procedure Unchecked_Free is new Ada.Unchecked_Deallocation
              (Allocate_Impl, Allocate_Impl_Ptr);
      Ptr : Allocate_Impl_Ptr := Allocate_Impl (Object.all)'Access;
   begin
      Unchecked_Free (Ptr);
   end Destroy;
   procedure Find (Object  : in out Allocate_Impl;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class;
                   Found   : out Boolean) is
      Stmt : ADO.Statements.Query_Statement
          := Session.Create_Statement (ALLOCATE_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      if Stmt.Has_Elements then
         Object.Load (Stmt, Session);
         Stmt.Next;
         Found := not Stmt.Has_Elements;
      else
         Found := False;
      end if;
   end Find;
   overriding
   procedure Load (Object  : in out Allocate_Impl;
                   Session : in out ADO.Sessions.Session'Class) is
      Found : Boolean;
      Query : ADO.SQL.Query;
      Id    : constant ADO.Identifier := Object.Get_Key_Value;
   begin
      Query.Bind_Param (Position => 1, Value => Id);
      Query.Set_Filter ("id = ?");
      Object.Find (Session, Query, Found);
      if not Found then
         raise ADO.Objects.NOT_FOUND;
      end if;
   end Load;
   procedure Save (Object  : in out Allocate_Impl;
                   Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Update_Statement
         := Session.Create_Statement (ALLOCATE_TABLE'Access);
   begin
      if Object.Is_Modified (1) then
         Stmt.Save_Field (Name  => COL_0_2_NAME, --  ID
                          Value => Object.Get_Key);
         Object.Clear_Modified (1);
      end if;
      if Object.Is_Modified (3) then
         Stmt.Save_Field (Name  => COL_2_2_NAME, --  NAME
                          Value => Object.Name);
         Object.Clear_Modified (3);
      end if;
      if Stmt.Has_Save_Fields then
         Object.Object_Version := Object.Object_Version + 1;
         Stmt.Save_Field (Name  => "object_version",
                          Value => Object.Object_Version);
         Stmt.Set_Filter (Filter => "id = ? and object_version = ?");
         Stmt.Add_Param (Value => Object.Get_Key);
         Stmt.Add_Param (Value => Object.Object_Version - 1);
         declare
            Result : Integer;
         begin
            Stmt.Execute (Result);
            if Result /= 1 then
               if Result = 0 then
                  raise ADO.Objects.LAZY_LOCK;
               else
                  raise ADO.Objects.UPDATE_ERROR;
               end if;
            end if;
         end;
      end if;
   end Save;
   procedure Create (Object  : in out Allocate_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Query : ADO.Statements.Insert_Statement
                  := Session.Create_Statement (ALLOCATE_TABLE'Access);
      Result : Integer;
   begin
      Object.Object_Version := 1;
      Session.Allocate (Id => Object);
      Query.Save_Field (Name  => COL_0_2_NAME, --  ID
                        Value => Object.Get_Key);
      Query.Save_Field (Name  => COL_1_2_NAME, --  object_version
                        Value => Object.Object_Version);
      Query.Save_Field (Name  => COL_2_2_NAME, --  NAME
                        Value => Object.Name);
      Query.Execute (Result);
      if Result /= 1 then
         raise ADO.Objects.INSERT_ERROR;
      end if;
      ADO.Objects.Set_Created (Object);
   end Create;
   procedure Delete (Object  : in out Allocate_Impl;
                     Session : in out ADO.Sessions.Master_Session'Class) is
      Stmt : ADO.Statements.Delete_Statement
         := Session.Create_Statement (ALLOCATE_TABLE'Access);
   begin
      Stmt.Set_Filter (Filter => "id = ?");
      Stmt.Add_Param (Value => Object.Get_Key);
      Stmt.Execute;
   end Delete;
   function Get_Value (Item : in Allocate_Ref;
                       Name : in String) return Util.Beans.Objects.Object is
      Impl : constant access Allocate_Impl
         := Allocate_Impl (Item.Get_Load_Object.all)'Access;
   begin
      if Name = "id" then
         return ADO.Objects.To_Object (Impl.Get_Key);
      end if;
      if Name = "name" then
         return Util.Beans.Objects.To_Object (Impl.Name);
      end if;
      raise ADO.Objects.NOT_FOUND;
   end Get_Value;
   procedure List (Object  : in out Allocate_Vector;
                   Session : in out ADO.Sessions.Session'Class;
                   Query   : in ADO.SQL.Query'Class) is
      Stmt : ADO.Statements.Query_Statement := Session.Create_Statement (ALLOCATE_TABLE'Access);
   begin
      Stmt.Set_Parameters (Query);
      Stmt.Execute;
      Allocate_Vectors.Clear (Object);
      while Stmt.Has_Elements loop
         declare
            Item : Allocate_Ref;
            Impl : constant Allocate_Access := new Allocate_Impl;
         begin
            Impl.Load (Stmt, Session);
            ADO.Objects.Set_Object (Item, Impl.all'Access);
            Object.Append (Item);
         end;
         Stmt.Next;
      end loop;
   end List;
   --  ------------------------------
   --  Load the object from current iterator position
   --  ------------------------------
   procedure Load (Object  : in out Allocate_Impl;
                   Stmt    : in out ADO.Statements.Query_Statement'Class;
                   Session : in out ADO.Sessions.Session'Class) is
      pragma Unreferenced (Session);
   begin
      Object.Set_Key_Value (Stmt.Get_Identifier (0));
      Object.Name := Stmt.Get_Unbounded_String (2);
      Object.Object_Version := Stmt.Get_Integer (1);
      ADO.Objects.Set_Created (Object);
   end Load;

end Regtests.Simple.Model;
