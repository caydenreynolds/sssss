package generic

import (
	"encoding/binary"
	"errors"
	"github.com/google/uuid"
	"ssssserver/pkg/venom"
)

func NewAuthToken() (*venom.AuthToken, error) {
	v4, err := uuid.NewRandom()
	if err != nil {
		return nil, err
	}
	bytes, err := v4.MarshalBinary()
	if err != nil {
		return nil, err
	}
	return AuthTokenFromBytes(bytes)
}

func AuthTokenFromBytes(bytes []byte) (*venom.AuthToken, error) {
	if len(bytes) != 16 {
		return nil, errors.New("Wrong number of bytes to create auth token")
	}
	return &venom.AuthToken{
		MostSignificant:  binary.LittleEndian.Uint64(bytes[0:8]),
		LeastSignificant: binary.LittleEndian.Uint64(bytes[8:16]),
	}, nil
}
