-----------------------------------------------------------------------
--  ado-queries -- Database Queries
--  Copyright (C) 2009, 2010, 2011, 2012, 2013, 2014, 2015 Stephane Carrez
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

with Util.Strings;
with Util.Refs;
with ADO.SQL;
with ADO.Drivers;

with Interfaces;
with Ada.Strings.Unbounded;

--  == Introduction ==
--  Ada Database Objects provides a small framework which helps in
--  using complex SQL queries in an application.
--  The benefit of the framework are the following:
--
--    * The SQL query result are directly mapped in Ada records,
--    * It is easy to change or tune an SQL query without re-building the application,
--    * The SQL query can be easily tuned for a given database
--
--  The database query framework uses an XML query file:
--
--    * The XML query file defines a mapping that represents the result of SQL queries,
--    * The XML mapping is used by [http://code.google.com/p/ada-gen Dynamo] to generate an Ada record,
--    * The XML query file also defines a set of SQL queries, each query being identified by a unique name,
--    * The XML query file is read by the application to obtain the SQL query associated with a query name,
--    * The application uses the `List` procedure generated by [http://code.google.com/p/ada-gen Dynamo].
--
--  == XML Query File and Mapping ==
--  === XML Query File ===
--  The XML query file uses the `query-mapping` root element.  It should
--  define at most one `class` mapping and several `query` definitions.
--  The `class` definition should come first before any `query` definition.
--
--    <query-mapping>
--       <class>...</class>
--       <query>...</query>
--    </query-mapping>
--
--  == SQL Result Mapping ==
--  The XML query mapping is very close to the database table mapping.
--  The difference is that there is no need to specify and table name
--  nor any SQL type.  The XML query mapping is used to build an Ada
--  record that correspond to query results.  Unlike the database table mapping,
--  the Ada record will not be tagged and its definition will expose all the record
--  members directly.
--
--  The following XML query mapping:
--
--    <query-mapping>
--      <class name='Samples.Model.User_Info'>
--        <property name="name" type="String">
--           <comment>the user name</comment>
--        </property>
--        <property name="email" type="String">
--           <comment>the email address</comment>
--        </property>
--      </class>
--    </query-mapping>
--
--  will generate the following Ada record:
--
--    package Samples.Model is
--       type User_Info is record
--         Name  : Unbounded_String;
--         Email : Unbounded_String;
--       end record;
--    end Samples.Model;
--
--  The same query mapping can be used by different queries.
--
--  === SQL Queries ===
--  The XML query file defines a list of SQL queries that the application
--  can use.  Each query is associated with a unique name.  The application
--  will use that name to identify the SQL query to execute.  For each query,
--  the file also describes the SQL query pattern that must be used for
--  the query execution.
--
--    <query name='xxx' class='Samples.Model.User_Info'>
--       <sql driver='mysql'>
--         select u.name, u.email from user
--       </sql>
--       <sql driver='sqlite'>
--          ...
--       </sql>
--       <sql-count driver='mysql'>
--          select count(*) from user u
--       </sql-count>
--    </query>
--
--  The query contains basically two SQL patterns.  The `sql` element represents
--  the main SQL pattern.  This is the SQL that is used by the `List` operation.
--  In some cases, the result set returned by the query is limited to return only
--  a maximum number of rows.  This is often use in paginated lists.
--
--  The `sql-count` element represents an SQL query to indicate the total number
--  of elements if the SQL query was not limited.
package ADO.Queries is

   type Query_File;
   type Query_File_Access is access all Query_File;

   type Query_Definition;
   type Query_Definition_Access is access all Query_Definition;

   type Query_Info is limited private;
   type Query_Info_Access is access all Query_Info;

   type Query_Info_Ref_Access is private;

   Null_Query_Info_Ref : constant Query_Info_Ref_Access;

   --  ------------------------------
   --  Query Context
   --  ------------------------------
   --  The <b>Context</b> type holds the necessary information to build and execute
   --  a query whose SQL pattern is defined in an XML query file.
   type Context is new ADO.SQL.Query with private;

   --  Set the query definition which identifies the SQL query to execute.
   --  The query is represented by the <tt>sql</tt> XML entry.
   procedure Set_Query (Into  : in out Context;
                        Query : in Query_Definition_Access);

   --  Set the query count definition which identifies the SQL query to execute.
   --  The query count is represented by the <tt>sql-count</tt> XML entry.
   procedure Set_Count_Query (Into  : in out Context;
                              Query : in Query_Definition_Access);

   --  Set the query to execute as SQL statement.
   procedure Set_SQL (Into : in out Context;
                      SQL  : in String);

   procedure Set_Query (Into  : in out Context;
                        Name  : in String);

   --  Set the limit for the SQL query.
   procedure Set_Limit (Into  : in out Context;
                        First : in Natural;
                        Last  : in Natural);

   --  Get the first row index.
   function Get_First_Row_Index (From : in Context) return Natural;

   --  Get the last row index.
   function Get_Last_Row_Index (From : in Context) return Natural;

   --  Get the maximum number of rows that the SQL query can return.
   --  This operation uses the <b>sql-count</b> query.
   function Get_Max_Row_Count (From : in Context) return Natural;

   --  Get the SQL query that correspond to the query context.
   function Get_SQL (From   : in Context;
                     Driver : in ADO.Drivers.Driver_Index) return String;

   --  ------------------------------
   --  Query Definition
   --  ------------------------------
   --  The <b>Query_Definition</b> holds the SQL query pattern which is defined
   --  in an XML query file.  The query is identified by a name and a given XML
   --  query file can contain several queries.  The Dynamo generator generates
   --  one instance of <b>Query_Definition</b> for each query defined in the XML
   --  file.  The XML file is loaded during application initialization (or later)
   --  to get the SQL query pattern.  Multi-thread concurrency is achieved by
   --  the Query_Info_Ref atomic reference.
   type Query_Definition is limited record
      --  The query name.
      Name   : Util.Strings.Name_Access;

      --  The query file in which the query is defined.
      File   : Query_File_Access;

      --  The next query defined in the query file.
      Next   : Query_Definition_Access;

      --  The SQL query pattern (initialized when reading the XML query file).
      Query  : Query_Info_Ref_Access;
   end record;

   function Get_SQL (From      : in Query_Definition_Access;
                     Driver    : in ADO.Drivers.Driver_Index;
                     Use_Count : in Boolean) return String;

   --  ------------------------------
   --  Query File
   --  ------------------------------
   --  The <b>Query_File</b> describes the SQL queries associated and loaded from
   --  a given XML query file.  The Dynamo generator generates one instance of
   --  <b>Query_File</b> for each XML query file that it has read.  The Path,
   --  Sha1_Map, Queries and Next are initialized statically by the generator (during
   --  package elaboration).
   type Query_File is limited record
      --  Query relative path name
      Name          : Util.Strings.Name_Access;

      --  Query absolute path name (after path resolution).
      Path          : Ada.Strings.Unbounded.String_Access;

      --  The SHA1 hash of the query map section.
      Sha1_Map      : Util.Strings.Name_Access;

      --  Stamp when the query file will be checked.
      Next_Check    : Interfaces.Unsigned_32;

      --  Stamp identifying the modification date of the query file.
      Last_Modified : Interfaces.Unsigned_32;

      --  The first query defined for that file.
      Queries       : Query_Definition_Access;

      --  The next XML query file registered in the application.
      Next          : Query_File_Access;
   end record;

private

   type Context is new ADO.SQL.Query with record
      First      : Natural := 0;
      Last       : Natural := 0;
      Last_Index : Natural := 0;
      Max_Row_Count : Natural := 0;
      Query_Def  : Query_Definition_Access := null;
      Is_Count   : Boolean := False;
   end record;

   --  Find the query with the given name.
   --  Returns the query definition that matches the name or null if there is none
   function Find_Query (File : in Query_File;
                        Name : in String) return Query_Definition_Access;

   use Ada.Strings.Unbounded;

   --  SQL query pattern
   type Query_Pattern is limited record
      SQL : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   type Query_Pattern_Array is array (ADO.Drivers.Driver_Index) of Query_Pattern;

   type Query_Info is new Util.Refs.Ref_Entity with record
      Main_Query  : Query_Pattern_Array;
      Count_Query : Query_Pattern_Array;
   end record;

   package Query_Info_Ref is
      new Util.Refs.References (Query_Info, Query_Info_Access);

   type Query_Info_Ref_Access is access all Query_Info_Ref.Atomic_Ref;

   Null_Query_Info_Ref : constant Query_Info_Ref_Access := null;

end ADO.Queries;
