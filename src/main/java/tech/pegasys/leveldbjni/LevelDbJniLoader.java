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

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import org.fusesource.leveldbjni.internal.NativeDB;

/**
 * Provides utilities to load leveldb native libraries with better architecture support than is
 * provided by the standard load process.
 */
public class LevelDbJniLoader {

  /**
   * Loads the LevelDB native library.
   *
   * <p>Must be called before the first reference to {@link org.fusesource.leveldbjni.JniDBFactory}.
   */
  public static void loadNativeLibrary() {
    final String libName = System.mapLibraryName("leveldbjni").replace(".dylib", ".jnilib");
    final String resName = System.getProperty("os.name").replaceFirst(" .*", "")
        + "/" + System.getProperty("os.arch")
        + "/" + libName;

    final String baseResourcePath = "META-INF/native/";
    final ClassLoader classLoader = LevelDbJniLoader.class.getClassLoader();
    try (final InputStream resource =
        classLoader.getResourceAsStream(baseResourcePath + resName)) {

      if (resource != null) {
        final Path tmpDir = Files.createTempDirectory("leveldbjni@");
        tmpDir.toFile().deleteOnExit();
        final Path tmpFile = tmpDir.resolve(libName);
        tmpFile.toFile().deleteOnExit();
        Files.copy(resource, tmpFile, StandardCopyOption.REPLACE_EXISTING);
        System.setProperty("library.leveldbjni.path", tmpDir.toAbsolutePath().toString());

        NativeDB.LIBRARY.load();
      }
    } catch (final IOException e) {
      throw new UncheckedIOException(e);
    }
  }
}
