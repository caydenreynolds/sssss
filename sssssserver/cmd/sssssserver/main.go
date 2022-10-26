package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"ssssserver/pkg/db"
	"ssssserver/pkg/service"
	"ssssserver/pkg/session"
	"ssssserver/pkg/venom"

	"google.golang.org/grpc"
)

func main() {
	dbUser := flag.String("usr", "", "Username for connecting to the database")
	dbPass := flag.String("pwd", "", "Password for connecting to the database")
	dataDir := flag.String("datadir", "", "Directory to store uploaded files in")

	flag.Parse()
	if *dbUser == "" {
		fmt.Println("No usr argument passed")
		flag.Usage()
		os.Exit(1)
	}
	if *dbPass == "" {
		fmt.Println("No pwd argument passed")
		flag.Usage()
		os.Exit(1)
	}
	if *dataDir == "" {
		fmt.Println("No datadir argument passed")
		flag.Usage()
		os.Exit(1)
	}

	dbConn, err := db.Connect(*dbUser, *dbPass)
	if err != nil {
		panic(err)
	}
	sessionBook := session.NewSessionBook(dbConn)

	lis, err := net.Listen("tcp", ":42069")
	if err != nil {
		log.Fatalf("failed to listen: %v\n", err)
	}
	server := grpc.NewServer()
	venom.RegisterPingServiceServer(server, &service.PongService{})
	authService := service.NewAuthService(dbConn, &sessionBook)
	venom.RegisterAuthServiceServer(server, &authService)
	fileService := service.NewFileService(dbConn, &sessionBook)
	venom.RegisterFileServiceServer(server, &fileService)

	go func() {
		log.Printf("sssssserver listening at %v", lis.Addr())
		if err := server.Serve(lis); err != nil {
			log.Fatalf("failed to serve: %v\n", err)
		}
	}()

	service.FileServiceListen(*dataDir, &sessionBook)
}
