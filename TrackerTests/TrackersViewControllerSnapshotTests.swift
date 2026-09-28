import CoreData
import SnapshotTesting
import UIKit
import XCTest

@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {

    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = makeInMemoryContext()
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    // MARK: - Empty

    func testEmptyLight() {
        assertMainScreen(style: .light)
    }

    func testEmptyDark() {
        assertMainScreen(style: .dark)
    }

    // MARK: - With trackers

    func testWithTrackersLight() {
        seedTrackers()
        assertMainScreen(style: .light)
    }

    func testWithTrackersDark() {
        seedTrackers()
        assertMainScreen(style: .dark)
    }

    // MARK: - Helpers

    private func assertMainScreen(
        style: UIUserInterfaceStyle,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let categoryStore = TrackerCategoryStore(context: context)
        let viewModel = TrackersViewModel(
            trackerStore: TrackerStore(
                context: context,
                categoryStore: categoryStore
            ),
            recordStore: TrackerRecordStore(context: context),
            currentDate: Self.fixedDate
        )
        let tabBarController = TabBarViewController(
            trackersViewController: TrackersViewController(viewModel: viewModel),
            statisticsViewController: UIViewController()
        )

        assertSnapshot(
            of: tabBarController,
            as: .image(
                drawHierarchyInKeyWindow: true,
                traits: .init(userInterfaceStyle: style)
            ),
            file: file,
            testName: testName,
            line: line
        )
    }

    private func seedTrackers() {
        let everyDay = "1,2,3,4,5,6,7"

        let home = makeCategory("Домашний уют", order: 0)
        let joys = makeCategory("Радостные мелочи", order: 1)

        let plants = makeTracker(
            "Поливать растения",
            emoji: "❤️",
            colorHex: "#33CF69",
            schedule: everyDay,
            category: home,
            order: 0
        )
        makeTracker(
            "Кошка заслонила камеру на созвоне",
            emoji: "😻",
            colorHex: "#FF881E",
            schedule: everyDay,
            category: joys,
            order: 1
        )
        makeTracker(
            "Бабушка прислала открытку в вотсапе",
            emoji: "🌺",
            colorHex: "#FD4C49",
            schedule: everyDay,
            category: joys,
            order: 2
        )

        let record = TrackerRecordCoreData(context: context)
        record.trackerId = plants.id
        record.date = Calendar.current.startOfDay(for: Self.fixedDate)
        record.tracker = plants

        XCTAssertNoThrow(try context.save())
    }

    private func makeCategory(
        _ title: String,
        order: TimeInterval
    ) -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        category.createdAt = Date(timeIntervalSince1970: order)
        return category
    }

    @discardableResult
    private func makeTracker(
        _ name: String,
        emoji: String,
        colorHex: String,
        schedule: String,
        category: TrackerCategoryCoreData,
        order: TimeInterval
    ) -> TrackerCoreData {
        let tracker = TrackerCoreData(context: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.emoji = emoji
        tracker.colorHex = colorHex
        tracker.schedule = schedule
        tracker.createdAt = Date(timeIntervalSince1970: order)
        tracker.category = category
        return tracker
    }

    private func makeInMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        return container.viewContext
    }

    private static let fixedDate: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 28
        return Calendar.current.date(from: components) ?? Date()
    }()
}
