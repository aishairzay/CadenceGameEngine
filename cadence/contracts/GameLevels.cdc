pub contract interface GameLevels {
  pub fun createLevel(_ name: String): AnyStruct? {
    return nil
  }
  
  pub fun getAvailableLevels(): [String] {
    return []
  }
}
