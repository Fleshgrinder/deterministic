import avro.Key;
import org.apache.avro.io.EncoderFactory;
import org.apache.avro.specific.SpecificDatumWriter;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;

public class AvroMain {
    public static void main(String[] args) throws IOException {
        System.setProperty("org.apache.avro.specific.use_custom_coders", "true");

        final Key key = new Key();
        key.booleanValue = true;
        key.bytesValue = ByteBuffer.wrap("bytes".getBytes(StandardCharsets.UTF_8));
        key.doubleValue = 42.42;
        key.floatValue = 42.42f;
        key.intValue = 42;
        key.longValue = 42;
        key.stringValue = "string";

        new SpecificDatumWriter<>(Key.class).write(
                key,
                EncoderFactory.get().binaryEncoder(System.out, null)
        );
    }
}
