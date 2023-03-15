({
    init: function (cmp) {
        var items = [];
        for (var i = 0; i < 15; i++) {
            var item = {
                "label": "Option " + i,
                "value": "opt" + i
            };
            items.push(item);
        }
        cmp.set("v.options", items);
        // "values" must be a subset of values from "options"
        cmp.set("v.values", ["opt10", "opt5", "opt7"]);
    },

    handleChange: function (cmp, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
    }
});