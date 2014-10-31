
import QtTest 1.0
import QtQuick 2.1

import org.edgenet.qml.drops 1.0


Item {
  TestCase {
    id: test
    name: "Drops"
    
    Drops {
      id:subject
      path: "/tmp/drops_test"
    }
    
    function test_selfTest() {
      var verbose = false
      Drops.selfTest(verbose)
    }
    
    function test_it() {
      compare(subject.running, false)
      
      subject.start()
      compare(subject.running, true)
      
      console.log(subject)
      wait(1000)
      
      subject.stop()
      compare(subject.running, false)
    }
  }
}
