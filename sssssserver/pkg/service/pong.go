package service

import (
	"context"
	"fmt"
	"ssssserver/pkg/venom"
)

type PongService struct {
	venom.UnimplementedPingServiceServer
}

func (s *PongService) PingPong(_ context.Context, in *venom.Ping) (*venom.Pong, error) {
	fmt.Printf("Received a message: %s\n", in.Message)
	return &venom.Pong{Message: in.Message}, nil
}
