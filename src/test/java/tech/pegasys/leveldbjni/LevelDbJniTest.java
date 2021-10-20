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
