
  
  USING Progress.Json.ObjectModel.*.
  VAR JsonArray oToolsArray.

  
  def var ob as web.api.mcp.tools. 
  ob = new web.api.mcp.tools(). 
  
  
  oToolsArray = ob:getRegisteredtools().
  oToolsArray:WriteFile("log/tools_config.json", TRUE). 
 
  message web.api.mcp.tools:GetToolClassName('restart_pasoe') view-as alert-box.

   
  //   web.api.mcp.tools:InstantiateAllTools().  
  //   web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools\system') . 
  //   web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools\automagic').
  //   web.api.mcp.tools:InstantiateToolsInDirectory('web\api\mcp\tools').
