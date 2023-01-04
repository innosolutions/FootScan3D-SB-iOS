import UIKit

print("download the file from Astrivis")
let parameters: Parameters = [
    "key": "xoadieHae5iF0ChieZoowaes2sho2ep3",
    "filename": self.store_filename
]

AF.request(Utils.getApiAddress(key: Utils.ASTRIVIS_DOWNLOAD_URL), method: .post, parameters: parameters).responseJSON { response in
    print("Request: \(String(describing: response.request))")   // original url request
    print("Response: \(String(describing: response.response))") // http url response
    print("Result: \(response.result)")                         // response serialization result
    
    if let json = response.result.value {
        print("JSON: \(json)") // serialized json response
    }
    
    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
        print("Data: \(utf8Text)") // original server data as UTF8 string
    }
    
    if response.response?.statusCode == 202 {
        
    }else if response.response?.statusCode == 200{
        self.performSegue(withIdentifier: "loginSucessSegue", sender: self)
    }
    
}
var str = "Hello, playground"
