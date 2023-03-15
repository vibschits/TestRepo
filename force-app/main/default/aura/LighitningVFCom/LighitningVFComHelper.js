({
	getVisualForceDomainHelper : function(component,event) {
		var action = component.get("c.getVisualforceDomain");
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var visualForceDomain = response.getReturnValue();
                component.set("v.vfHost",visualForceDomain);
                var vfOrigin =  component.get("v.vfHost");
                var instrumentation_Key = component.get("v.InstrumentationKey");
                var name_space = component.get("v.NameSpace");
                var vfOrigin = "https://" + component.get("v.vfHost");
                var vfWindow = component.find("vfFrame").getElement().contentWindow;
                var send_Message = instrumentation_Key +','+name_space;
                vfWindow.postMessage(send_Message, vfOrigin);
            }    
         });
        $A.enqueueAction(action);
	}
})