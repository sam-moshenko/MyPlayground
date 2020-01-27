import Foundation

protocol Food {
    var name: String { get }
}

protocol Animal {
    associatedtype Food
    func feed(_ food: Food) -> String
}

extension Animal {
    func feedPrint(_ food: Food) {
        print("I ate \(feed(food))")
    }
}

struct AnyAnimal<Food>: Animal {
    let feedClosure: (Food) -> String

    init<Base: Animal>(base: Base) where Food == Base.Food {
        feedClosure = base.feed
    }

    func feed(_ food: Food) -> String {
        return feedClosure(food)
    }
}

struct CarFood: Food {
    var name: String = "Oil"
}

struct Grass: Food {
    var name: String = "Grass"
}

struct Cow: Animal {
    func feed(_ food: Grass) -> String {
        return "Green \(food.name)"
    }

    typealias Food = Grass
}
struct Car: Animal {
    typealias Food = CarFood

    func feed(_ food: CarFood) -> String {
        return "Great \(food.name)"
    }
}

let cow = AnyAnimal(base: Cow())
let car = AnyAnimal(base: Car())
cow.feedPrint(Grass())
car.feedPrint(CarFood())


