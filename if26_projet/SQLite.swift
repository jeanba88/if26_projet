//
//  SQLite.swift
//  if26_projet
//
//  Created by Jean-baptiste Blot on 16/12/2017.
//  Copyright © 2017 Jean-baptiste Blot. All rights reserved.
//

import Foundation
import SQLite

class Database {
    var database: Connection!
    let gareTable = Table("gare")
    let trajetTable = Table("trajet")
    let departTable = Table("depart")
    // TABLE GARE
    let id_gare = Expression<String>("id_gare")
    let name_gare = Expression<String>("name_gare")
    // TABLE TRAJET
    let id_trajet = Expression<Int>("id_trajet")
    let gareDepart = Expression<String>("gare_depart")
    let gareArrive = Expression<String>("gare_arrive")
    
    // TABLE DEPART
    let id_depart = Expression<Int>("id_depart")
    let heureDepart = Expression<String>("heure_depart")
    let heureArrive = Expression<String>("heure_arrive")
    let duree = Expression<Int>("duree")
    
    
    init() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("if26projet").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        }catch { print(error)}
    }
    
    func createTable() {
        let createTableGare = self.gareTable.create{(table) in
            table.column(self.id_gare, primaryKey: true)
            table.column(self.name_gare)
        }
        let createTableTrajet = self.trajetTable.create{(table) in
            table.column(self.id_trajet, primaryKey: true)
            table.column(self.gareDepart)
            table.column(self.gareArrive)
            table.foreignKey(self.gareDepart, references: self.gareTable, self.id_gare)
            table.foreignKey(self.gareArrive, references: self.gareTable, self.id_gare)
        }
        let createTableDepart = self.departTable.create{(table) in
            table.column(self.id_depart, primaryKey: true)
            table.column(self.id_trajet)
            table.column(self.heureDepart)
            table.column(self.heureArrive)
            table.column(self.duree)
            table.foreignKey(self.id_trajet, references: self.trajetTable, self.id_trajet)
        }
        do {
            try self.database.run(createTableGare)
            try self.database.run(createTableTrajet)
            try self.database.run(createTableDepart)
        } catch { print(error)}
    }
    
    func insertGare(gare: Gare) {
        do {
            let insert = self.gareTable.insert(or: .ignore,self.id_gare <- gare.id, self.name_gare <- gare.name)
            try self.database.run(insert)
        } catch {
            print(error)
        }
    }
    func selectGare() -> [Gare] {
        var listGare:[Gare] = []
        do {
            for gare in try self.database.prepare(self.gareTable) {
                listGare.append(Gare.init(id: gare[self.id_gare], name: gare[self.name_gare]))
                }
        } catch {
            print("Erreur")
        }
        return listGare
    }
    func selectGare(id_gare: String) -> Gare?{
        do {
            for gare in try self.database.prepare(self.gareTable.filter(self.id_gare == id_gare)) {
                return Gare.init(id: gare[self.id_gare], name: gare[self.name_gare])
            }
        } catch {
            print(error)
        }
        return nil
    }
    func deleteGare(id_gare: String) {
        do {
            let gare = self.gareTable.filter(self.id_gare == id_gare)
            let gareDelete = gare.delete()
            try self.database.run(gareDelete)
        } catch {
            print(error)
        }
    }
    func insertTrajet(trajet: Trajet) {
        insertGare(gare: trajet.gareDepart!)
        insertGare(gare: trajet.gareArrive!)
        
        let insertQuery = self.trajetTable.insert(self.gareDepart <- trajet.gareDepart!.id, self.gareArrive <- trajet.gareArrive!.id)
        do {
            try self.database.run(insertQuery)
            
        } catch {
            print(error)
        }
    }
    
    func selectTrajet() -> [Trajet] {
        var listTrajet:[Trajet] = []
        do{
            for trajet in try self.database.prepare(self.trajetTable) {
                listTrajet.append(Trajet(gareDepart: self.selectGare(id_gare: trajet[self.gareDepart])!, gareArrive: self.selectGare(id_gare: trajet[self.gareArrive])!, id_trajet: trajet[self.id_trajet]))
            }
        }catch { print(error) }
        return listTrajet
    }
    func selectTrajet(gareDepart: Gare, gareArrive: Gare) -> Trajet? {
        do{
            for trajet in try self.database.prepare(self.trajetTable.filter(self.gareDepart == gareDepart.id && self.gareArrive == gareArrive.id)) {
                return Trajet(gareDepart: self.selectGare(id_gare: trajet[self.gareDepart])!, gareArrive: self.selectGare(id_gare: trajet[self.gareArrive])!, id_trajet: trajet[self.id_trajet])
            }
        }catch { print(error) }
        return nil
    }
    func selectTrajet(id_trajet: Int) -> Trajet? {
        do{
            for trajet in try self.database.prepare(self.trajetTable.filter(self.id_trajet == id_trajet)) {
                return Trajet(gareDepart: self.selectGare(id_gare: trajet[self.gareDepart])!, gareArrive: self.selectGare(id_gare: trajet[self.gareArrive])!, id_trajet: trajet[self.id_trajet])
            }
        }catch { print(error) }
        return nil
    }
    func findOrInsert(trajet: Trajet) {
        if(trajet.gareDepart != nil && trajet.gareArrive != nil && self.selectTrajet(gareDepart: trajet.gareDepart!, gareArrive: trajet.gareArrive!) == nil){
            self.insertTrajet(trajet: trajet)
        }
    }
    func deleteTrajet(id_trajet: Int) {
        do {
            let trajet = self.trajetTable.filter(self.id_trajet == id_trajet)
            let trajetDelete = trajet.delete()
            try self.database.run(trajetDelete)
        } catch {
            print("Erreur lors de la suppression")
        }
    }
    
}