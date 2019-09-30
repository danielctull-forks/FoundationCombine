
import Foundation
import Combine

extension Collection where Element: Publisher {

    /// Combine the array of publishers to give a single array of the `Zip ` of their outputs
    public var zip: AnyPublisher<[Element.Output], Element.Failure> {

        let count = self.count
        var iteration = 1

        return self
            .map { $0.scan(into: []) { $0.append($1) }}
            .combineLatest
            .compactMap { values -> [Element.Output]? in

                let current = values.map { outputs -> Element.Output? in
                    let elements = outputs.prefix(iteration)
                    guard elements.count == iteration else { return nil }
                    return elements.last
                }

                let output = current.compactMap { $0 }
                guard output.count == count else { return nil }
                iteration += 1
                return output
            }
            .eraseToAnyPublisher()
    }
}
