({
	getVisualForceDomainHelper : function(component,event) {
           var instrumentationKey_sbx = component.get("v.InstrumentationKey");
                var instrumentationKey_prod = component.get("v.InstrumentationKey_prod");
                var page_Name = component.get("v.pagename");
                var name_space = component.get("v.NameSpace");
         var vfWindow = component.find("vfFrame").getElement().contentWindow;
        var send_Message = instrumentationKey_sbx +','+instrumentationKey_prod+','+name_space+','+page_Name;
         vfWindow.postMessage(send_Message, '*');
		
	}
})