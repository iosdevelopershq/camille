extension String {
    func containsOnly<T: Sequence>(characters: T) -> Bool where T.Iterator.Element == Character {
        for c in self.characters {
            if (!characters.contains(c)) { return false }
        }
        return true
    }
}
