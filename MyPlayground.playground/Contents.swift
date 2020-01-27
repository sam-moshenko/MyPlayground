import Foundation

protocol Food {
    var name: String { get }
}

protocol Animal: class {
    associatedtype Food
    var lastEatenFood: Food? { get set }
    func feed(_ food: Food) -> String
}

extension Animal {
    func feedPrint(_ food: Food) {
        print("I ate \(feed(food))")
        lastEatenFood = food
    }
}

class AnyAnimal<Food>: Animal {
    var lastEatenFood: Food?
    let getLastEatenFood: () -> Food?
    let setLastEatenFood: (Food?) -> Void
    let feedClosure: (Food) -> String

    init<Base: Animal>(base: Base) where Food == Base.Food {
        feedClosure = base.feed
        getLastEatenFood = {
            return base.lastEatenFood
        }
        setLastEatenFood = {
            base.lastEatenFood = $0
        }
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

class Cow: Animal {
    var lastEatenFood: Grass? = nil

    func feed(_ food: Grass) -> String {
        return "Green \(food.name)"
    }

    typealias Food = Grass
}

class Car: Animal {
    var lastEatenFood: CarFood? = nil

    typealias Food = CarFood

    func feed(_ food: CarFood) -> String {
        return "Great \(food.name)"
    }
}

var cow = Cow()
var car = Car()
let cowWrap = AnyAnimal(base: cow)
let carWrap = AnyAnimal(base: car)
cowWrap.feedPrint(Grass())
carWrap.feedPrint(CarFood())

cowWrap.lastEatenFood
carWrap.lastEatenFood
