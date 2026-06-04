package com.mke84.bettboxt

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.Button
import android.widget.TextView
import android.widget.Toast

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val tvWelcome: TextView = findViewById(R.id.tvWelcome)
        val btnHello: Button = findViewById(R.id.btnHello)

        btnHello.setOnClickListener {
            Toast.makeText(this, "Hello from native Android!", Toast.LENGTH_SHORT).show()
        }
    }
}
