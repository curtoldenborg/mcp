
  
  USING Progress.Json.ObjectModel.*.
  VAR JsonArray oToolsArray.

  
  def var ob as web.api.mcp.tools. 
  ob = new web.api.mcp.tools(). 

  oToolsArray = ob:getRegisteredtools().
  oToolsArray:WriteFile("log/tools_config.json", TRUE). 

   
  //   web.api.mcp.tools:InstantiateAllTools().  
  //   web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools\system') . 
  //   web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools\automagic').
  //   web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools').
