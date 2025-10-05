import Foundation

protocol ToDoService {
    func fetchToDos(completion: @escaping (Result<[ToDoDTO], Error>) -> Void)
}

class ToDoServiceImpl: ToDoService {
    func fetchToDos(completion: @escaping (Result<[ToDoDTO], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            return completion(.failure(NSError(domain: "BadURL", code: -1)))
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            guard let data = data else {
                print("Couldn't fetch data")
                return DispatchQueue.main.async {
                    completion(.success([]))
                }
            }
            
            do {
                let decoder = try JSONDecoder().decode(TodoListResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoder.todos)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
            
        }
        task.resume()
    }
}
