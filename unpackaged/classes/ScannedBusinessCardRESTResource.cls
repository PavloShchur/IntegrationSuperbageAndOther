@RestResource(urlMapping='/businessCard')
global class ScannedBusinessCardRESTResource {
    
    @HttpGet
    global static void doGet() {
                
        ScannedBusinessCardRESTService.doGet();
        
    }
    
    @HttpPost
    global static void doPost() {
                        
        ScannedBusinessCardRESTService.doPost();
        
    }
}