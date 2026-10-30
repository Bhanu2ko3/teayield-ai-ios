import Foundation
import CoreLocation

/// Mock sample data used for SwiftUI previews and offline unit tests.
enum MockData {

    // MARK: - Nuwara Eliya Estate Sample IDs
    
    static let nuwaraEliyaEstateId = UUID(uuidString: "3b241101-5231-4822-a982-f87c126d4001")!
    static let nuwaraEliyaEstateCentroid = CLLocationCoordinate2D(latitude: 6.9642, longitude: 80.7932)

    // MARK: - User Profiles
    
    static let supervisor = UserProfile(
        id: UUID(uuidString: "55555555-6666-7777-8888-999999999999")!,
        email: "supervisor@nuwaraeliya.estate.lk",
        fullName: "Kusal Bandara",
        role: .fieldSupervisor,
        employeeId: "SUP-402",
        phoneNumber: "+94 77 123 4567",
        estateId: nuwaraEliyaEstateId
    )
    
    static let manager = UserProfile(
        id: UUID(uuidString: "66666666-7777-8888-9999-000000000000")!,
        email: "manager@nuwaraeliya.estate.lk",
        fullName: "Bhanuka Bandara",
        role: .estateManager,
        employeeId: "MGR-082",
        phoneNumber: "+94 71 890 1234",
        estateId: nuwaraEliyaEstateId
    )

    // MARK: - Tea Fields
    
    static let fieldBlockA = TeaField(
        id: UUID(uuidString: "7c9e6679-7425-40de-944b-e07fc1f90ae7")!,
        estateId: nuwaraEliyaEstateId,
        name: "Upper Division Block A",
        blockCode: "UD-BLK-A",
        acreage: 12.50,
        currentNDVI: 0.820,
        status: .ready,
        centroidLatitude: 6.9642,
        centroidLongitude: 80.7932,
        polygonCoordinates: [
            CoordinatePair(latitude: 6.9650, longitude: 80.7925),
            CoordinatePair(latitude: 6.9655, longitude: 80.7940),
            CoordinatePair(latitude: 6.9635, longitude: 80.7945),
            CoordinatePair(latitude: 6.9630, longitude: 80.7930)
        ],
        lastHarvestedDate: Calendar.current.date(byAdding: .day, value: -9, to: Date())
    )
    
    static let fieldBlockB = TeaField(
        id: UUID(uuidString: "8d1f7780-8536-41ef-055c-f18fd2a01bf8")!,
        estateId: nuwaraEliyaEstateId,
        name: "Middle Valley Block B",
        blockCode: "MV-BLK-B",
        acreage: 15.00,
        currentNDVI: 0.740,
        status: .growing,
        centroidLatitude: 6.9610,
        centroidLongitude: 80.7960,
        polygonCoordinates: [
            CoordinatePair(latitude: 6.9620, longitude: 80.7950),
            CoordinatePair(latitude: 6.9625, longitude: 80.7970),
            CoordinatePair(latitude: 6.9600, longitude: 80.7975),
            CoordinatePair(latitude: 6.9595, longitude: 80.7955)
        ],
        lastHarvestedDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())
    )
    
    static let fieldBlockC = TeaField(
        id: UUID(uuidString: "9e2a8891-9647-42f0-166d-a29fe3b12ca9")!,
        estateId: nuwaraEliyaEstateId,
        name: "Lower Ravine Block C",
        blockCode: "LR-BLK-C",
        acreage: 9.80,
        currentNDVI: 0.580,
        status: .resting,
        centroidLatitude: 6.9585,
        centroidLongitude: 80.7915,
        polygonCoordinates: [
            CoordinatePair(latitude: 6.9595, longitude: 80.7905),
            CoordinatePair(latitude: 6.9600, longitude: 80.7925),
            CoordinatePair(latitude: 6.9575, longitude: 80.7930),
            CoordinatePair(latitude: 6.9570, longitude: 80.7910)
        ],
        lastHarvestedDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())
    )
    
    static let sampleFields: [TeaField] = [fieldBlockA, fieldBlockB, fieldBlockC]

    // MARK: - Plucking Tasks
    
    static let taskToday = PluckingTask(
        id: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
        fieldId: UUID(uuidString: "7c9e6679-7425-40de-944b-e07fc1f90ae7")!,
        fieldName: "Upper Division Block A",
        blockCode: "UD-BLK-A",
        assignedPluckersCount: 25,
        targetWeightKg: 850.0,
        harvestedWeightKg: 620.5,
        shiftDate: Date(),
        isCompleted: false,
        centroidLatitude: 6.9642,
        centroidLongitude: 80.7932
    )
    
    static let completedTask = PluckingTask(
        id: UUID(uuidString: "22222222-3333-4444-5555-666666666666")!,
        fieldId: UUID(uuidString: "8d1f7780-8536-41ef-055c-f18fd2a01bf8")!,
        fieldName: "Middle Valley Block B",
        blockCode: "MV-BLK-B",
        assignedPluckersCount: 18,
        targetWeightKg: 500.0,
        harvestedWeightKg: 512.0,
        shiftDate: Date(),
        isCompleted: true,
        centroidLatitude: 6.9610,
        centroidLongitude: 80.7960
    )
    
    static let sampleTasks: [PluckingTask] = [taskToday, completedTask]

    // MARK: - Harvest Records
    
    static let harvestRecord1 = HarvestRecord(
        id: UUID(uuidString: "33333333-4444-5555-6666-777777777777")!,
        fieldId: UUID(uuidString: "7c9e6679-7425-40de-944b-e07fc1f90ae7")!,
        pluckerId: "EMP-4012",
        pluckerName: "K. Meenakshi",
        grossWeightKg: 28.5,
        tareWeightKg: 1.2,
        netWeightKg: 27.3,
        fineLeafRatio: 0.88,
        timestamp: Date(),
        latitude: 6.9642,
        longitude: 80.7932,
        isSynced: false
    )
    
    static let harvestRecord2 = HarvestRecord(
        id: UUID(uuidString: "44444444-5555-6666-7777-888888888888")!,
        fieldId: UUID(uuidString: "7c9e6679-7425-40de-944b-e07fc1f90ae7")!,
        pluckerId: "EMP-4013",
        pluckerName: "S. Kamalasani",
        grossWeightKg: 26.0,
        tareWeightKg: 1.2,
        netWeightKg: 24.8,
        fineLeafRatio: 0.86,
        timestamp: Date().addingTimeInterval(-1800),
        latitude: 6.9645,
        longitude: 80.7930,
        isSynced: true
    )
    
    static let sampleHarvestRecords: [HarvestRecord] = [harvestRecord1, harvestRecord2]

    // MARK: - Plucker Workforce
    
    static let plucker1 = Plucker(
        id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000001")!,
        estateId: nuwaraEliyaEstateId,
        pluckerCode: "EMP-4012",
        fullName: "K. Meenakshi",
        averageDailyRateKg: 28.5,
        isActive: true
    )
    
    static let plucker2 = Plucker(
        id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000002")!,
        estateId: nuwaraEliyaEstateId,
        pluckerCode: "EMP-4013",
        fullName: "S. Kamalasani",
        averageDailyRateKg: 26.2,
        isActive: true
    )
    
    static let plucker3 = Plucker(
        id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000003")!,
        estateId: nuwaraEliyaEstateId,
        pluckerCode: "EMP-4018",
        fullName: "P. Loganathan",
        averageDailyRateKg: 31.0,
        isActive: true
    )
    
    static let plucker4 = Plucker(
        id: UUID(uuidString: "11111111-aaaa-bbbb-cccc-000000000004")!,
        estateId: nuwaraEliyaEstateId,
        pluckerCode: "EMP-4022",
        fullName: "M. Saraswathi",
        averageDailyRateKg: 27.8,
        isActive: true
    )

    static let samplePluckers: [Plucker] = [plucker1, plucker2, plucker3, plucker4]
}
