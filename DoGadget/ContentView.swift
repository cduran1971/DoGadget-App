//
//  ContentView.swift
//  DoGadget
//
//  Created by Celso Duran on 2/9/23.
//

import SwiftUI
import CoreData
import CoreBluetooth

class BluetoothViewModel : NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "unnamed devie")
        }
    }
}
 
struct ContentView: View {
    struct DataListView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
            animation: .default)
        
        private var items: FetchedResults<Item>
        
        var body: some View {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("\(item.timestamp!, formatter: timeStampFormatter)")
                        Text(String(format: "Lat: %.5f, Long: %.5f", item.lat, item.long))
                        Text(String(format: "Pull: %.2f, Threshold: %.2f", item.pull_force, item.pull_threshold))
                    } label: {
                        Text(item.timestamp!, formatter: timeStampFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            Text("Select a Date/Time")
        }
        private func deleteItems(offsets: IndexSet){
            withAnimation {
                offsets.map { items[$0] }.forEach(viewContext.delete)

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    struct BTDevicesView: View {
        @ObservedObject private var bluetoothViewModel = BluetoothViewModel()
        
        var body: some View {
            NavigationView {
                List(bluetoothViewModel.peripheralNames, id: \.self) {
                    peripheral in Text(peripheral)
                }
                Text("Select a DoGadget to connect to")
                //.navigationTitle("Discovered Devices")
            }
            
        }
    }
        
    var body: some View {
        NavigationStack {
            Text("")
                .navigationTitle("DoGadget")
            VStack {
                NavigationLink(destination: BTDevicesView()) {
                        Text("Connect to DoGadget")
                }
                .padding()
                NavigationLink(destination: DataListView()) {
                    Text("Data List")
                }
            }
        }
    }
}

private let timeStampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
