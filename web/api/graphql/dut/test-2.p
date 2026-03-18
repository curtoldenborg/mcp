
/*

MESSAGE NUM-ENTRIES("dfas fadsf fads posts|filter: $filter|",'|') 
 NUM-ENTRIES("posts",'')
VIEW-AS ALERT-BOX. 
*/
           /*
FOR EACH _Index  WHERE _Unique,
    EACH _File OF _Index WHERE _File._File-num > 0  AND  _File._File-name = "customer" :
    
    DISP _index. 
END. 
         */
FOR EACH _file ,EACH _index OF _file  WHERE _File._File-num > 0  AND  _File._File-name = "customer" AND  _index._Unique:
     DISP _index. 
END.
