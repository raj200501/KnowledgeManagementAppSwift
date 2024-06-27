import CoreML
import Vision

class MLModelHandler {

    static let shared = MLModelHandler()

    private init() {}

    func classifyEntry(title: String, content: String, completion: @escaping (String?) -> Void) {
        guard let model = try? VNCoreMLModel(for: MyMLModel().model) else {
            completion(nil)
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil)
                return
            }
            completion(topResult.identifier)
        }

        let text = "\(title) \(content)"
        guard let data = text.data(using: .utf8) else {
            completion(nil)
            return
        }

        let handler = VNDocumentCameraViewController()
        handler.text = data
        handler.perform([request])
    }
}
