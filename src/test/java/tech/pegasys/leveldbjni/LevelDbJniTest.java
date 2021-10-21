/*
 * Copyright 2021 ConsenSys AG.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */
package tech.pegasys.leveldbjni;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.file.Path;
import org.fusesource.leveldbjni.JniDBFactory;
import org.iq80.leveldb.DB;
import org.iq80.leveldb.Options;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

public class LevelDbJniTest {

  static {
    LevelDbJniLoader.loadNativeLibrary();
  }

  private DB db;

  @AfterEach
  void tearDown() throws Exception {
    if (db != null) {
      db.close();
    }
  }

  @Test
  void shouldLoadLevelDbNativeLibrary(@TempDir Path tmpDir) throws Exception {
    db = JniDBFactory.factory.open(tmpDir.toFile(), new Options().createIfMissing(true));
    final byte[] key = {1, 2, 3};
    final byte[] value = {4, 5, 6};
    db.put(key, value);
    assertThat(db.get(key)).isEqualTo(value);
  }
}
