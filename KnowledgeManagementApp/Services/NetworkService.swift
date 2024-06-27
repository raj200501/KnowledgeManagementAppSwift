import Foundation

class NetworkService {

    static let shared = NetworkService()

    private init() {}

    func uploadEntry(_ entry: Entry, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:5000/entry") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(entry)
            let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
            task.resume()
        } catch {
            print("Error encoding entry: \(error.localizedDescription)")
            completion(false)
        }
    }
}
