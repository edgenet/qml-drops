
import QtTest 1.0
import QtQuick 2.1

import org.jemc.qml.Drops 1.0


Item {
  TestCase {
    id: test
    name: "Drops"
    
    Drops { id:subject }
    
    function test_it() {
      console.log(subject)
    }
    
  }
}
