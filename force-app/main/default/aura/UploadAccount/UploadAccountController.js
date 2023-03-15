({
    CreateRecord: function (component, event, helper) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if (file) {
        console.log("File");
        var reader = new FileReader();
        reader.readAsText(file, "UTF-8");
        reader.onload = function (evt) {
            console.log("EVT FN");
            var csv = evt.target.result;
            console.log('@@@ csv file contains'+ csv);
            var result = helper.CSV2JSON(component,csv);
            console.log('@@@ result = ' + result);
            //console.log('@@@ Result = '+JSON.parse(result));
            helper.CreateAccount(component,result);
            
        }
        reader.onerror = function (evt) {
            console.log("error reading file");
        }
    }

    }
    
    
})