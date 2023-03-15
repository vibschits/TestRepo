public class ProdUpdateCheck {
    // SK-011222 Finding whether price of the product is updated or not through custom label
        @AuraEnabled
        public static string productUpdate(){
            List<String> prodUpdateVal = new List<String>();
            string produpdateLbl = Label.Product_price_update;
            string prodUpdateValue = String.format(prodUpdateLbl, prodUpdateVal);
            System.debug('Product Label Value'+ prodUpdateValue);
            return prodUpdateValue;
        }
    }