//
//  CountdownWidget.swift
//  countdown
//
//  Created by David Estelle on 20/4/25.
//  
//

import PockKit
import AppKit

final class CountdownWidget: NSObject {
    private var labelView: NSTextField!
    private var timer: Timer?
    private var targetDate: Date?

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        labelView = NSTextField(labelWithString: "Loading...")
        labelView.alignment = .center
        labelView.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        labelView.textColor = .white
        labelView.sizeToFit()

        // Load saved time from UserDefaults
        if let savedTime = UserDefaults.standard.value(forKey: "CountdownTargetTime") as? Double {
            targetDate = Date(timeIntervalSince1970: savedTime)
        }

        startTimer()
    }

    // MARK: - PKWidget Conformance
    // Providing the required methods for conformance to PKWidget protocol

    func identifier() -> String {
        return "dev.davidestelle.countdown"  // A unique identifier for the widget
    }

    func view() -> NSView {
        return labelView  // This view will be displayed on the Touch Bar
    }

    func widgetWillBeRemoved() {
        timer?.invalidate()  // Clean up timer when widget is removed
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateLabel()
        }
    }

    private func updateLabel() {
        guard let target = targetDate else {
            labelView.stringValue = "No date"
            return
        }

        let interval = target.timeIntervalSinceNow
        if interval <= 0 {
            labelView.stringValue = "00:00:00"
        } else {
            let hours = Int(interval) / 3600
            let minutes = (Int(interval) % 3600) / 60
            let seconds = Int(interval) % 60
            labelView.stringValue = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}

// MARK: - PKWidgetPreferences Conformance

extension CountdownWidget: PKWidgetPreferences {
    var preferencesView: NSView {
        let view = NSStackView()
        view.orientation = .vertical
        view.spacing = 10

        // Date picker for setting countdown time
        let datePicker = NSDatePicker()
        datePicker.datePickerStyle = .clockAndCalendar
        datePicker.datePickerElements = [.hourMinute, .yearMonthDay]
        datePicker.dateValue = targetDate ?? Date()

        // Button to save the selected date
        let saveButton = NSButton(title: "Save", target: nil, action: nil)
        saveButton.action = #selector(saveDate(_:))
        saveButton.target = self

        view.addArrangedSubview(datePicker)
        view.addArrangedSubview(saveButton)

        datePicker.tag = 100  // Tag for identifying the date picker

        return view
    }

    @objc func saveDate(_ sender: NSButton) {
        // Retrieve the date from the date picker
        guard let preferencesView = sender.superview as? NSStackView,
              let picker = preferencesView.viewWithTag(100) as? NSDatePicker else { return }

        self.targetDate = picker.dateValue
        // Save the selected date to UserDefaults for persistent storage
        UserDefaults.standard.set(picker.dateValue.timeIntervalSince1970, forKey: "CountdownTargetTime")
        updateLabel()  // Update the label immediately after saving the date
    }
}

