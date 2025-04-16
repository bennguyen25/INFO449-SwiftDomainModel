struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    public var amount: Int
    public var currency: String
    
    public init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
        let validCurrencies = ["USD", "EUR", "GBP", "CAN"]
        if !validCurrencies.contains(currency) {
            fatalError("Invalid currency \(currency)")
        }
    }
    
    public func convert(_ to: String) -> Money {
        let toUSD: [String: Double] = [
            "USD": 1.0,
            "GBP": 2.0,
            "EUR": (2.0 / 3.0),
            "CAN": 0.8
        ]
        let fromUSD: [String: Double] = [
            "USD": 1.0,
            "GBP": 0.5,
            "EUR": 1.5,
            "CAN": 1.25
        ]
    
        guard let usdRate = toUSD[self.currency], let targetRate = fromUSD[to] else {
            fatalError("Invalid conversion rates.")
        }
        
        let amountInUSD = Double(self.amount) * usdRate
        let convertedAmount = amountInUSD * targetRate
        let finalAmount = Int(convertedAmount.rounded())
        
        return Money(amount: finalAmount, currency: to)
    }
    
    public func add(_ other: Money) -> Money {
        let convertedSelf = self.convert(other.currency)
        return Money(amount: convertedSelf.amount + other.amount, currency: other.currency)
    }
    
    public func subtract(_ other: Money) -> Money {
        let convertedSelf = self.convert(other.currency)
        return Money(amount: convertedSelf.amount - other.amount, currency: other.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    public var title: String
    public var type: JobType
    
    public init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    public func calculateIncome(_ hours: Int) -> Int {
        switch type {
        case .Hourly(let rate):
            return Int(rate * Double(hours))
        case .Salary(let salary):
            return Int(salary)
        }
    }
    public func raise(byAmount amount: Double) {
        switch type {
        case .Hourly(let rate):
            self.type = .Hourly(rate + amount)
        case .Salary(let salary):
            self.type = .Salary(salary + UInt(amount))
        }
    }
    
    public func raise(byPercent percent: Double) {
        switch type {
        case .Hourly(let rate):
            self.type = .Hourly(rate * (1 + percent))
        case .Salary(let salary):
            let newSalary = Double(salary) + Double(salary) * percent
            self.type = .Salary(UInt(newSalary))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    public let firstName: String
    public let lastName: String
    public let age: Int
    
    private var _job: Job? = nil
    private var _spouse: Person? = nil
    
    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    public var job: Job? {
        get { return _job }
        set {
            if self.age >= 16 {
                _job = newValue
            }
        }
    }
    
    public var spouse: Person? {
        get { return _spouse }
        set {
            if self.age >= 16 {
                _spouse = newValue
            }
        }
    }
    
    public func toString() -> String {
        let jobStr = job == nil ? "nil" : "\(job!)"
        let spouseStr = spouse == nil ? "nil" : "\(spouse!.firstName)"
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(jobStr) spouse:\(spouseStr)]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    public var members: [Person] = []
    
    public init(spouse1: Person, spouse2: Person) {
        spouse2.spouse = spouse1
        spouse1.spouse = spouse2
        self.members = [spouse1, spouse2]
    }
    
    public func haveChild(_ child: Person) -> Bool {
        let spouse1 = members[0]
        let spouse2 = members[1]
        
        if spouse1.age <= 21 || spouse2.age <= 21 {
            return false
        }
        
        members.append(child)
        return true
    }
    
    public func householdIncome() -> Int {
        var totalIncome = 0
        
        for person in members {
            if let job = person.job {
                switch job.type {
                case .Hourly(_):
                    totalIncome += job.calculateIncome(2000)
                case .Salary(_):
                    totalIncome += job.calculateIncome(0)
                }
            }
        }
        return totalIncome
    }
}
