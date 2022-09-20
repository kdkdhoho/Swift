import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

//    var values: [Any]!
    var result: [String] = []
    
    var receiveData: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for data in values {
//            let tmp: Dictionary<String, String> = data as! Dictionary<String, String>
//            result.append(tmp["name"]!)
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return values!.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "valueCell", for: indexPath)
        
        // Before
//        cell.textLabel?.text = result[indexPath.row]
        
        // After
        if(receiveData is Int) {
            cell.textLabel?.text = String((receiveData as? Int)!)
        }
        else {
            cell.textLabel?.text = receiveData as? String
        }
        
        return cell
    }
}


