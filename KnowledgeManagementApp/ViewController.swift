import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveEntry(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            showAlert(message: "Please enter both title and content.")
            return
        }

        let entry = Entry(title: title, content: content)
        StorageService.shared.saveEntry(entry)
        NetworkService.shared.uploadEntry(entry) { success in
            if success {
                self.showAlert(message: "Entry saved and uploaded successfully.")
            } else {
                self.showAlert(message: "Failed to upload entry.")
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
