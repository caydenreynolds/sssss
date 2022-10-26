package service

import (
	"golang.org/x/crypto/bcrypt"
	"testing"
)

const pwd = "as34I8A&%mn!p"

func BenchmarkHash10(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 10)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}

func BenchmarkHash11(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 11)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}

func BenchmarkHash12(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 12)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}

func BenchmarkHash13(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 13)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}

func BenchmarkHash14(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 14)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}

func BenchmarkHash15(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 15)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}

func BenchmarkHash16(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 16)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}

func BenchmarkHash17(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 17)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}

func BenchmarkHash18(b *testing.B) {
	for n := 0; n < b.N; n++ {
		hash, _ := bcrypt.GenerateFromPassword([]byte(pwd), 18)
		bcrypt.CompareHashAndPassword(hash, []byte(pwd))
	}
}
