import com.google.protobuf.ByteString;
import proto.Key;
import sun.misc.Unsafe;

import java.io.IOException;
import java.lang.reflect.Field;

public class ProtoMain {
    public static void main(String[] args) throws IOException {
        try {
            final Field theUnsafe = Unsafe.class.getDeclaredField("theUnsafe");
            theUnsafe.setAccessible(true);
            final Unsafe u = (Unsafe) theUnsafe.get(null);

            final Class<?> cls = Class.forName("jdk.internal.module.IllegalAccessLogger");
            final Field logger = cls.getDeclaredField("logger");
            u.putObjectVolatile(cls, u.staticFieldOffset(logger), null);
        } catch (Exception e) {
            // ignore
        }

        final Key protoKey = Key.newBuilder()
                .setBoolValue(true)
                .setBytesValue(ByteString.copyFromUtf8("bytes"))
                .setDoubleValue(42.42)
                .setFixed32Value(42)
                .setFixed64Value(42)
                .setFloatValue(42.42f)
                .setInt32Value(42)
                .setInt64Value(42)
                .setSfixed32Value(42)
                .setSfixed64Value(42)
                .setStringValue("string")
                .setUint32Value(42)
                .setUint64Value(42)
                .addRepeatedValue(1)
                .addRepeatedValue(2)
                .addRepeatedValue(3)
                .setSomeValue("some")
                .setEnumeratedTypeValue(Key.EnumeratedType.SOME)
                .build();

        final Key key = protoKey.toBuilder()
                .setNestedMessageValue(protoKey)
                .build();

        System.out.write(key.toByteArray());
    }
}
