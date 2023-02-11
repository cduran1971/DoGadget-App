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
        switch central.state {
            case .poweredOff:
                print("Is Powered Off.")
            case .poweredOn:
                print("Is Powered On.")
                self.centralManager?.scanForPeripherals(withServices: nil)
            case .unsupported:
                print("Is Unsupported.")
            case .unauthorized:
                print("Is Unauthorized.")
            case .unknown:
                print("Unknown")
            case .resetting:
                print("Resetting")
            @unknown default:
                print("Error")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "unnamed device")
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
        
        /*init() {
            for _ in 0..<10 {
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.lat = 10.05432
                newItem.long = -2.22345
                newItem.pull_force = 10.02
                newItem.pull_threshold = 20.55
                
                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }*/
            
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
        
        private func addItem() {
            withAnimation {
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.lat = 10.05432
                newItem.long = -2.22345
                newItem.pull_force = 10.02
                newItem.pull_threshold = 20.55
                
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
            List(bluetoothViewModel.peripheralNames, id: \.self) {
                peripheral in Text(peripheral)
            }
            Text("Select a DoGadget to connect to")
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
