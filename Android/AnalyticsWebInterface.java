package com.lpointdsc.aos;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.widget.Toast;

import com.google.firebase.analytics.FirebaseAnalytics;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;

public class AnalyticsWebInterface {

    private WebView mWebView;
    private final Handler mHandler = new Handler();

    private FirebaseInterface ieFirebase;
    public static final String TAG = "AnalyticsWebInterface";
    private Activity mActivity;

    public AnalyticsWebInterface(Activity activity) {
        mActivity = activity;
        ieFirebase = new FirebaseInterface(mActivity);
    }

    // Firebase LogEvent
    @JavascriptInterface
    public void logEvent(String event_name, String event_paramsJson) {
        LOGD("logEvent:" + event_name);
        ieFirebase.logEvent(event_name, event_paramsJson);
    }

    // Firebase SetUserProperty
    @JavascriptInterface
    public void setUserProperty(String property_name, String property_value) {
        LOGD("setUserProperty:" + property_name);
        ieFirebase.setUserProperty(property_name, property_value);
    }

    // Firebase SetCurrentScreen
    @JavascriptInterface
    public void setScreenName(String screen_name) {
        LOGD("setScreenName:" + screen_name);
        ieFirebase.setScreenName(mActivity, screen_name);
    }

    private void LOGD(String message) {
        // Only log on debug builds, for privacy
        if (BuildConfig.DEBUG) {
            Log.d(TAG, message);
        }
    }

    private Bundle bundleFromJson(String json) {
        if(TextUtils.isEmpty(json)) {
            return new Bundle();
        }

        Bundle result = new Bundle();

        try {
            JSONObject jsonObj = new JSONObject(json);
            Iterator<String> keys = jsonObj.keys();

            ArrayList items = new ArrayList();

            while (keys.hasNext()) {
                String key = keys.next();
                Object value = jsonObj.get(key);

                if (value instanceof String) {
                    result.putString(key, (String)value);
                } else if (value instanceof Integer) {
                    result.putInt(key, (Integer)value);
                } else if (value instanceof Double) {
                    result.putDouble(key, (Double)value);
                } else if (value instanceof JSONArray) {
                    JSONArray itemsArray = (JSONArray)value;

                    for (int i=0; i<itemsArray.length(); i++) {
                        JSONObject itemObj = itemsArray.getJSONObject(i);
                        Bundle item = new Bundle();

                        Iterator<String> keyList = itemObj.keys();
                        while(keyList.hasNext()) {
                            String itemKey = keyList.next();
                            Object itemValue = itemObj.get(itemKey);

                            if (itemValue instanceof String) {
                                item.putString(key, (String)value);
                            } else if (itemValue instanceof Integer) {
                                item.putInt(key, (Integer)value);
                            } else if (itemValue instanceof Double) {
                                item.putDouble(key, (Double)value);
                            }
                        }

                        items.add(item);

                    }
                    result.putParcelableArrayList(FirebaseAnalytics.Param.ITEMS, items);

                } else {
                    Log.w(TAG, "Value for key " + key + "not one of [String, Integer, Double, Array]");
                }
            }


        } catch(JSONException e) {
            Log.w(TAG, "Faild to parse JSON, returning empty Bundle.", e);
        }

        return result;
    }

}
