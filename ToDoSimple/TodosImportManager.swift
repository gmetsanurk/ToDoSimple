import Foundation

class TodosImportManager {
    
    public func getTodos(completion: @escaping (Result<[ToDoTask], Error>) -> Void) {
        
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
    }
}
