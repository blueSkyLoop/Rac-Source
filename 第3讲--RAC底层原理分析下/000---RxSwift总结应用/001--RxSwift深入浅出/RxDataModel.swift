//
//  RxDataModel.swift
//  001--RxSwift深入浅出
//
//  Created by Cooci on 2018/5/26.
//  Copyright © 2018年 Cooci. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct DataModel {
    let despStr:String
    let nameStr:String
}

struct InfoViewModel {
    var arr = Array<DataModel>()
    init(){
        arr.append(DataModel(despStr: "first", nameStr: "Cooci"))
        arr.append(DataModel(despStr: "2", nameStr: "Gavin"))
        arr.append(DataModel(despStr: "3", nameStr: "James"))
        arr.append(DataModel(despStr: "4", nameStr: "Dean"))
        arr.append(DataModel(despStr: "5", nameStr: "Kody"))
    }
}


struct SectionDataModel {
    
    let name: String
    let gitHubID: String
    var image: UIImage?
    
    init(name: String, gitHubID: String) {
        self.name = name
        self.gitHubID = gitHubID
        image = UIImage(named: gitHubID)
    }
}


extension SectionDataModel:IdentifiableType{
    typealias Identity = String
    var identity:Identity {return gitHubID}
}


class GithubData {
    let githubData = Observable.just([
        SectionModel(model: "A", items: [
            SectionDataModel(name: "Alex V Bush", gitHubID: "alexvbush"),
            SectionDataModel(name: "Andrew Breckenridge", gitHubID: "AndrewSB"),
            SectionDataModel(name: "Anton Efimenko", gitHubID: "reloni"),
            SectionDataModel(name: "Ash Furrow", gitHubID: "ashfurrow"),
            ]),
        SectionModel(model: "B", items: [
            SectionDataModel(name: "Ben Emdon", gitHubID: "BenEmdon"),
            SectionDataModel(name: "Bob Spryn", gitHubID: "sprynmr"),
            ]),
        SectionModel(model: "C", items: [
            SectionDataModel(name: "Carlos García", gitHubID: "carlosypunto"),
            SectionDataModel(name: "Cezary Kopacz", gitHubID: "CezaryKopacz"),
            SectionDataModel(name: "Chris Jimenez", gitHubID: "PiXeL16"),
            SectionDataModel(name: "Christian Tietze", gitHubID: "DivineDominion"),
            ]),
        SectionModel(model: "D", items: [
            SectionDataModel(name: "だいちろ", gitHubID: "mokumoku"),
            SectionDataModel(name: "David Alejandro", gitHubID: "davidlondono"),
            SectionDataModel(name: "David Paschich", gitHubID: "dpassage"),
            ]),
        SectionModel(model: "E", items: [
            SectionDataModel(name: "Esteban Torres", gitHubID: "esttorhe"),
            SectionDataModel(name: "Evgeny Aleksandrov", gitHubID: "ealeksandrov"),
            ]),
        SectionModel(model: "F", items: [
            SectionDataModel(name: "Florent Pillet", gitHubID: "fpillet"),
            SectionDataModel(name: "Francis Chong", gitHubID: "siuying"),
            ]),
        SectionModel(model: "G", items: [
            SectionDataModel(name: "Giorgos Tsiapaliokas", gitHubID: "terietor"),
            SectionDataModel(name: "Guy Kahlon", gitHubID: "GuyKahlon"),
            SectionDataModel(name: "Gwendal Roué", gitHubID: "groue"),
            ]),
        SectionModel(model: "H", items: [
            SectionDataModel(name: "Hiroshi Kimura", gitHubID: "muukii"),
            ]),
        SectionModel(model: "I", items: [
            SectionDataModel(name: "Ivan Bruel", gitHubID: "ivanbruel"),
            ]),
        SectionModel(model: "J", items: [
            SectionDataModel(name: "Jeon Suyeol", gitHubID: "devxoul"),
            SectionDataModel(name: "Jérôme Alves", gitHubID: "jegnux"),
            SectionDataModel(name: "Jesse Farless", gitHubID: "solidcell"),
            SectionDataModel(name: "Junior B.", gitHubID: "bontoJR"),
            SectionDataModel(name: "Justin Swart", gitHubID: "justinswart"),
            ]),
        SectionModel(model: "K", items: [
            SectionDataModel(name: "Karlo", gitHubID: "floskel"),
            SectionDataModel(name: "Krunoslav Zaher", gitHubID: "kzaher"),
            ]),
        SectionModel(model: "L", items: [
            SectionDataModel(name: "Laurin Brandner", gitHubID: "lbrndnr"),
            SectionDataModel(name: "Lee Sun-Hyoup", gitHubID: "kciter"),
            SectionDataModel(name: "Leo Picado", gitHubID: "leopic"),
            SectionDataModel(name: "Libor Huspenina", gitHubID: "libec"),
            SectionDataModel(name: "Lukas Lipka", gitHubID: "lipka"),
            SectionDataModel(name: "Łukasz Mróz", gitHubID: "sunshinejr"),
            ]),
        SectionModel(model: "M", items: [
            SectionDataModel(name: "Marin Todorov", gitHubID: "icanzilb"),
            SectionDataModel(name: "Maurício Hanika", gitHubID: "mAu888"),
            SectionDataModel(name: "Maximilian Alexander", gitHubID: "mbalex99"),
            ]),
        SectionModel(model: "N", items: [
            SectionDataModel(name: "Nathan Kot", gitHubID: "nathankot"),
            ]),
        SectionModel(model: "O", items: [
            SectionDataModel(name: "Orakaro", gitHubID: "DTVD"),
            SectionDataModel(name: "Orta", gitHubID: "orta"),
            ]),
        SectionModel(model: "P", items: [
            SectionDataModel(name: "Paweł Urbanek", gitHubID: "pawurb"),
            SectionDataModel(name: "Pedro Piñera Buendía", gitHubID: "pepibumur"),
            SectionDataModel(name: "PG Herveou", gitHubID: "pgherveou"),
            ]),
        SectionModel(model: "R", items: [
            SectionDataModel(name: "Rui Costa", gitHubID: "ruipfcosta"),
            SectionDataModel(name: "Ryo Fukuda", gitHubID: "yuzushioh"),
            ]),
        SectionModel(model: "S", items: [
            SectionDataModel(name: "Scott Gardner", gitHubID: "scotteg"),
            SectionDataModel(name: "Scott Hoyt", gitHubID: "scottrhoyt"),
            SectionDataModel(name: "Sendy Halim", gitHubID: "sendyhalim"),
            SectionDataModel(name: "Serg Dort", gitHubID: "sergdort"),
            SectionDataModel(name: "Shai Mishali", gitHubID: "freak4pc"),
            SectionDataModel(name: "Shams Ahmed", gitHubID: "shams-ahmed"),
            SectionDataModel(name: "Shenghan Chen", gitHubID: "zzdjk6"),
            SectionDataModel(name: "Shunki Tan", gitHubID: "milkit"),
            SectionDataModel(name: "Spiros Gerokostas", gitHubID: "sger"),
            SectionDataModel(name: "Stefano Mondino", gitHubID: "stefanomondino"),
            ]),
        SectionModel(model: "T", items: [
            SectionDataModel(name: "Thane Gill", gitHubID: "thanegill"),
            SectionDataModel(name: "Thomas Duplomb", gitHubID: "tomahh"),
            SectionDataModel(name: "Tomasz Pikć", gitHubID: "pikciu"),
            SectionDataModel(name: "Tony Arnold", gitHubID: "tonyarnold"),
            SectionDataModel(name: "Torsten Curdt", gitHubID: "tcurdt"),
            ]),
        SectionModel(model: "V", items: [
            SectionDataModel(name: "Vladimir Burdukov", gitHubID: "chipp"),
            ]),
        SectionModel(model: "W", items: [
            SectionDataModel(name: "Wolfgang Lutz", gitHubID: "Lutzifer"),
            ]),
        SectionModel(model: "X", items: [
            SectionDataModel(name: "xixi197 Nova", gitHubID: "xixi197"),
            ]),
        SectionModel(model: "Y", items: [
            SectionDataModel(name: "Yongha Yoo", gitHubID: "inkyfox"),
            SectionDataModel(name: "Yosuke Ishikawa", gitHubID: "ishkawa"),
            SectionDataModel(name: "Yury Korolev", gitHubID: "yury"),
            ]),
        ])
}
