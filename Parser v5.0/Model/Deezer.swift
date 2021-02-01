//
//  Deezer.swift
//  Parser v5.0
//
//  Created by enchtein on 30.01.2021.
//

import Foundation


struct GetData: Decodable {
    var data: [AllInfo]?
    var total: Int?
    var next: String?
    
    static func executeTask(with task: Task, completion: @escaping (_ isSuccess: Bool, _ response: (GetData, AllInfo)) -> ()) {
        var repStringURL = ""
        switch task {
        case .getAllGenres: repStringURL = "https://api.deezer.com/genre"
        case .getAllArtistsByGenre(let genreId): repStringURL = "https://api.deezer.com/genre/\(genreId)/artists"
        case .getAllSongByArtist(let artistId): repStringURL = "https://api.deezer.com/artist/\(artistId)/top?limit=50"
        case .getSearchResult(let searchtext): repStringURL = "https://api.deezer.com/search?q=\(searchtext)"
        case .getSongData(let songId): repStringURL = "https://api.deezer.com/track/\(songId)"
        }
        guard let repURL = URL(string: repStringURL) else {return}
        
        URLSession.shared.dataTask(with: repURL) { (data, response, error) in
            var result = GetData()
            var song = AllInfo()
            guard data != nil else {
                print("NO DATA")
                completion(false, (result, song))
                return
            }
            guard error == nil else {
                print(error!.localizedDescription)
                completion(false, (result, song))
                return
            }
            
            do {
                switch task {
                case .getAllGenres: result = try JSONDecoder().decode(GetData.self, from: data!)
                case .getAllArtistsByGenre(_): result = try JSONDecoder().decode(GetData.self, from: data!)
                case .getAllSongByArtist(_): result = try JSONDecoder().decode(GetData.self, from: data!)
                case .getSearchResult(_): result = try JSONDecoder().decode(GetData.self, from: data!)
                case .getSongData(_): song = try JSONDecoder().decode(AllInfo.self, from: data!)
                }
//                dump(result)
//                dump(song)
                
                completion(true, (result, song))
            } catch {
                print(error.localizedDescription)
                completion(false, (result, song))
            }
        }.resume()
    }
}

struct AllInfo: Decodable, Encodable {
    var id: Int?// ID жанра / артиста / песни (МЕНЯЕТСЯ!)
    var type: String? // +
    var name: String? // имя артиста или группы +
    var picture: String? // картинка артиста или группы +
    var tracklist: String? // плейлист артиста
    var title: String? // название песни +
    var duration: Int? // продолжительность песни в секундах +
    var rank: Int? // ранг песни! +
    var artist: Artist?
    var album: Album?
    
    
    func putObjectToUserDefaults() {
      if let storedData = UserDefaults.standard.object(forKey: "favorites") as? Data {
        if var favoritesRepo = try? PropertyListDecoder().decode([AllInfo].self, from: storedData) {
//            if !favoritesRepo.contains(where: {$0.id!.elementsEqual(self.id)}) {
            if !favoritesRepo.contains(where: {$0.id == self.id}) {
            favoritesRepo.append(self)
            self.putObjArrayToUserDefaults(favoritesRepo)
          }
          return
        }
      }
      self.putObjArrayToUserDefaults([self])
    }
    
    private func putObjArrayToUserDefaults(_ array: [AllInfo]) {
      UserDefaults.standard.setValue(try? PropertyListEncoder().encode(array), forKey: "favorites")
    }
}

struct Artist: Decodable, Encodable {
    var id: Int// ID артиста
    var type: String
    var name: String? // имя артиста или группы
    var tracklist: String? // плейлист артиста
}
struct Album: Decodable, Encodable {
    var id: Int
    var title: String
    var cover: String? //обложка альбома
}


enum Task {
    case getAllGenres
    case getAllArtistsByGenre(genre: Int)
    case getAllSongByArtist(artistId: Int)
    case getSearchResult(searchtext: String)
    case getSongData(songId: Int)
}

