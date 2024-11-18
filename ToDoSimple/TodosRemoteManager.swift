import Foundation

class TodosRemoteManager {
    
    func getTodos(completion: @escaping (Result<[ToDoTask], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2, userInfo: nil)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                completion(.success(decodedResponse.todos))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
