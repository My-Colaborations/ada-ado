-----------------------------------------------------------------------
--  ADO Drivers -- Database Drivers
--  Copyright (C) 2010, 2011, 2012, 2013, 2015, 2017, 2018 Stephane Carrez
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

with Util.Log.Loggers;

with Ada.IO_Exceptions;

package body ADO.Drivers is

   Log : constant Util.Log.Loggers.Logger := Util.Log.Loggers.Create ("ADO.Drivers");

   --  Global configuration properties (loaded by Initialize).
   Global_Config : Util.Properties.Manager;

   --  ------------------------------
   --  Initialize the drivers and the library by reading the property file
   --  and configure the runtime with it.
   --  ------------------------------
   procedure Initialize (Config : in String) is
   begin
      Log.Info ("Initialize using property file {0}", Config);

      begin
         Util.Properties.Load_Properties (Global_Config, Config);
      exception
         when Ada.IO_Exceptions.Name_Error =>
            Log.Error ("Configuration file '{0}' does not exist", Config);
      end;

      Initialize (Global_Config);
   end Initialize;

   --  ------------------------------
   --  Initialize the drivers and the library and configure the runtime with the given properties.
   --  ------------------------------
   procedure Initialize (Config : in Util.Properties.Manager'Class) is
   begin
      Global_Config := Util.Properties.Manager (Config);

      --  Initialize the drivers.
      ADO.Drivers.Initialize;
   end Initialize;

   --  ------------------------------
   --  Get the global configuration property identified by the name.
   --  If the configuration property does not exist, returns the default value.
   --  ------------------------------
   function Get_Config (Name    : in String;
                        Default : in String := "") return String is
   begin
      return Global_Config.Get (Name, Default);
   end Get_Config;

   --  ------------------------------
   --  Returns true if the global configuration property is set to true/on.
   --  ------------------------------
   function Is_On (Name   : in String) return Boolean is
      Value : constant String := Global_Config.Get (Name, "");
   begin
      return Value = "on" or Value = "true" or Value = "1";
   end Is_On;

   --  Initialize the drivers which are available.
   procedure Initialize is separate;

end ADO.Drivers;
