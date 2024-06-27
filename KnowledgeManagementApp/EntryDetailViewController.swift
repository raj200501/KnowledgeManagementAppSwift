import UIKit

class EntryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!

    var entry: Entry?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let entry = entry {
            titleLabel.text = entry.title
            contentTextView.text = entry.content
        }
    }
}
