package com.landet.landet.api;

import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

import java.lang.reflect.Type;

public class DateTimeTypeConverter implements JsonSerializer<DateTime>, JsonDeserializer<DateTime> {
    private static DateTimeFormatter isoDateFormat = DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");

    public static String toString(DateTime dateTime) {
        return dateTime != null ? isoDateFormat.print(dateTime.withZone(DateTimeZone.UTC)) : null;
    }
    // No need for an InstanceCreator since DateTime provides a no-args constructor
    @Override
    public JsonElement serialize(DateTime src, Type srcType, JsonSerializationContext context) {
        return new JsonPrimitive(toString(src));
    }
    @Override
    public DateTime deserialize(JsonElement json, Type type, JsonDeserializationContext context)
            throws JsonParseException {
        return new DateTime(json.getAsString(), DateTimeZone.UTC).withZone(DateTimeZone.getDefault());
    }
}
