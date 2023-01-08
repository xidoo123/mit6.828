
obj/user/httpd.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 5b 05 00 00       	call   80058c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 00 2a 80 00       	push   $0x802a00
  80003f:	e8 81 06 00 00       	call   8006c5 <cprintf>
	exit();
  800044:	e8 89 05 00 00       	call   8005d2 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec 20 04 00 00    	sub    $0x420,%esp
  80005a:	89 c3                	mov    %eax,%ebx
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005c:	68 00 02 00 00       	push   $0x200
  800061:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800067:	50                   	push   %eax
  800068:	53                   	push   %ebx
  800069:	e8 cb 14 00 00       	call   801539 <read>
  80006e:	83 c4 10             	add    $0x10,%esp
  800071:	85 c0                	test   %eax,%eax
  800073:	79 17                	jns    80008c <handle_client+0x3e>
			panic("failed to read");
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	68 04 2a 80 00       	push   $0x802a04
  80007d:	68 04 01 00 00       	push   $0x104
  800082:	68 13 2a 80 00       	push   $0x802a13
  800087:	e8 60 05 00 00       	call   8005ec <_panic>

		memset(req, 0, sizeof(*req));
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 0c                	push   $0xc
  800091:	6a 00                	push   $0x0
  800093:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800096:	50                   	push   %eax
  800097:	e8 f3 0c 00 00       	call   800d8f <memset>

		req->sock = sock;
  80009c:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  80009f:	83 c4 0c             	add    $0xc,%esp
  8000a2:	6a 04                	push   $0x4
  8000a4:	68 20 2a 80 00       	push   $0x802a20
  8000a9:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000af:	50                   	push   %eax
  8000b0:	e8 65 0c 00 00       	call   800d1a <strncmp>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	0f 85 95 00 00 00    	jne    800155 <handle_client+0x107>
  8000c0:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  8000c6:	eb 03                	jmp    8000cb <handle_client+0x7d>
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  8000c8:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  8000cb:	f6 03 df             	testb  $0xdf,(%ebx)
  8000ce:	75 f8                	jne    8000c8 <handle_client+0x7a>
		request++;
	url_len = request - url;
  8000d0:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
  8000d6:	89 de                	mov    %ebx,%esi
  8000d8:	29 fe                	sub    %edi,%esi

	req->url = malloc(url_len + 1);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	8d 46 01             	lea    0x1(%esi),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 e6 21 00 00       	call   8022cc <malloc>
  8000e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  8000e9:	83 c4 0c             	add    $0xc,%esp
  8000ec:	56                   	push   %esi
  8000ed:	57                   	push   %edi
  8000ee:	50                   	push   %eax
  8000ef:	e8 e8 0c 00 00       	call   800ddc <memmove>
	req->url[url_len] = '\0';
  8000f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000f7:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)

	// skip space
	request++;
  8000fb:	8d 73 01             	lea    0x1(%ebx),%esi
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	89 f0                	mov    %esi,%eax
  800103:	eb 03                	jmp    800108 <handle_client+0xba>

	version = request;
	while (*request && *request != '\n')
		request++;
  800105:	83 c0 01             	add    $0x1,%eax

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  800108:	0f b6 10             	movzbl (%eax),%edx
  80010b:	84 d2                	test   %dl,%dl
  80010d:	74 05                	je     800114 <handle_client+0xc6>
  80010f:	80 fa 0a             	cmp    $0xa,%dl
  800112:	75 f1                	jne    800105 <handle_client+0xb7>
		request++;
	version_len = request - version;
  800114:	29 f0                	sub    %esi,%eax
  800116:	89 c3                	mov    %eax,%ebx

	req->version = malloc(version_len + 1);
  800118:	83 ec 0c             	sub    $0xc,%esp
  80011b:	8d 40 01             	lea    0x1(%eax),%eax
  80011e:	50                   	push   %eax
  80011f:	e8 a8 21 00 00       	call   8022cc <malloc>
  800124:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  800127:	83 c4 0c             	add    $0xc,%esp
  80012a:	53                   	push   %ebx
  80012b:	56                   	push   %esi
  80012c:	50                   	push   %eax
  80012d:	e8 aa 0c 00 00       	call   800ddc <memmove>
	req->version[version_len] = '\0';
  800132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800135:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
	// if the file does not exist, send a 404 error using send_error
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
	panic("send_file not implemented");
  800139:	83 c4 0c             	add    $0xc,%esp
  80013c:	68 25 2a 80 00       	push   $0x802a25
  800141:	68 e2 00 00 00       	push   $0xe2
  800146:	68 13 2a 80 00       	push   $0x802a13
  80014b:	e8 9c 04 00 00       	call   8005ec <_panic>

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
		if (e->code == code)
			break;
		e++;
  800150:	83 c0 08             	add    $0x8,%eax
  800153:	eb 05                	jmp    80015a <handle_client+0x10c>
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  800155:	b8 00 40 80 00       	mov    $0x804000,%eax
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  80015a:	8b 10                	mov    (%eax),%edx
  80015c:	85 d2                	test   %edx,%edx
  80015e:	74 3e                	je     80019e <handle_client+0x150>
		if (e->code == code)
  800160:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800164:	74 08                	je     80016e <handle_client+0x120>
  800166:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  80016c:	75 e2                	jne    800150 <handle_client+0x102>
	}

	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  80016e:	8b 40 04             	mov    0x4(%eax),%eax
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	50                   	push   %eax
  800175:	52                   	push   %edx
  800176:	50                   	push   %eax
  800177:	52                   	push   %edx
  800178:	68 74 2a 80 00       	push   $0x802a74
  80017d:	68 00 02 00 00       	push   $0x200
  800182:	8d b5 dc fb ff ff    	lea    -0x424(%ebp),%esi
  800188:	56                   	push   %esi
  800189:	e8 69 0a 00 00       	call   800bf7 <snprintf>
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  80018e:	83 c4 1c             	add    $0x1c,%esp
  800191:	50                   	push   %eax
  800192:	56                   	push   %esi
  800193:	ff 75 dc             	pushl  -0x24(%ebp)
  800196:	e8 78 14 00 00       	call   801613 <write>
  80019b:	83 c4 10             	add    $0x10,%esp
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a4:	e8 75 20 00 00       	call   80221e <free>
	free(req->version);
  8001a9:	83 c4 04             	add    $0x4,%esp
  8001ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001af:	e8 6a 20 00 00       	call   80221e <free>

		// no keep alive
		break;
	}

	close(sock);
  8001b4:	89 1c 24             	mov    %ebx,(%esp)
  8001b7:	e8 41 12 00 00       	call   8013fd <close>
}
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5e                   	pop    %esi
  8001c4:	5f                   	pop    %edi
  8001c5:	5d                   	pop    %ebp
  8001c6:	c3                   	ret    

008001c7 <umain>:

void
umain(int argc, char **argv)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 40             	sub    $0x40,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  8001d0:	c7 05 20 40 80 00 3f 	movl   $0x802a3f,0x804020
  8001d7:	2a 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8001da:	6a 06                	push   $0x6
  8001dc:	6a 01                	push   $0x1
  8001de:	6a 02                	push   $0x2
  8001e0:	e8 c1 1d 00 00       	call   801fa6 <socket>
  8001e5:	89 c6                	mov    %eax,%esi
  8001e7:	83 c4 10             	add    $0x10,%esp
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	79 0a                	jns    8001f8 <umain+0x31>
		die("Failed to create socket");
  8001ee:	b8 46 2a 80 00       	mov    $0x802a46,%eax
  8001f3:	e8 3b fe ff ff       	call   800033 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  8001f8:	83 ec 04             	sub    $0x4,%esp
  8001fb:	6a 10                	push   $0x10
  8001fd:	6a 00                	push   $0x0
  8001ff:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800202:	53                   	push   %ebx
  800203:	e8 87 0b 00 00       	call   800d8f <memset>
	server.sin_family = AF_INET;			// Internet/IP
  800208:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  80020c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800213:	e8 43 01 00 00       	call   80035b <htonl>
  800218:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  80021b:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  800222:	e8 1a 01 00 00       	call   800341 <htons>
  800227:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  80022b:	83 c4 0c             	add    $0xc,%esp
  80022e:	6a 10                	push   $0x10
  800230:	53                   	push   %ebx
  800231:	56                   	push   %esi
  800232:	e8 dd 1c 00 00       	call   801f14 <bind>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	85 c0                	test   %eax,%eax
  80023c:	79 0a                	jns    800248 <umain+0x81>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  80023e:	b8 f0 2a 80 00       	mov    $0x802af0,%eax
  800243:	e8 eb fd ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	6a 05                	push   $0x5
  80024d:	56                   	push   %esi
  80024e:	e8 30 1d 00 00       	call   801f83 <listen>
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	85 c0                	test   %eax,%eax
  800258:	79 0a                	jns    800264 <umain+0x9d>
		die("Failed to listen on server socket");
  80025a:	b8 14 2b 80 00       	mov    $0x802b14,%eax
  80025f:	e8 cf fd ff ff       	call   800033 <die>

	cprintf("Waiting for http connections...\n");
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	68 38 2b 80 00       	push   $0x802b38
  80026c:	e8 54 04 00 00       	call   8006c5 <cprintf>
  800271:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800274:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  800277:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  80027e:	83 ec 04             	sub    $0x4,%esp
  800281:	57                   	push   %edi
  800282:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800285:	50                   	push   %eax
  800286:	56                   	push   %esi
  800287:	e8 51 1c 00 00       	call   801edd <accept>
  80028c:	89 c3                	mov    %eax,%ebx
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	85 c0                	test   %eax,%eax
  800293:	79 0a                	jns    80029f <umain+0xd8>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  800295:	b8 5c 2b 80 00       	mov    $0x802b5c,%eax
  80029a:	e8 94 fd ff ff       	call   800033 <die>
		}
		handle_client(clientsock);
  80029f:	89 d8                	mov    %ebx,%eax
  8002a1:	e8 a8 fd ff ff       	call   80004e <handle_client>
	}
  8002a6:	eb cf                	jmp    800277 <umain+0xb0>

008002a8 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8002b7:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8002ba:	c7 45 e0 00 50 80 00 	movl   $0x805000,-0x20(%ebp)
  8002c1:	0f b6 0f             	movzbl (%edi),%ecx
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8002c9:	0f b6 d9             	movzbl %cl,%ebx
  8002cc:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8002cf:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8002d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d5:	66 c1 e8 0b          	shr    $0xb,%ax
  8002d9:	89 c3                	mov    %eax,%ebx
  8002db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002de:	01 c0                	add    %eax,%eax
  8002e0:	29 c1                	sub    %eax,%ecx
  8002e2:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  8002e4:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  8002e6:	8d 72 01             	lea    0x1(%edx),%esi
  8002e9:	0f b6 d2             	movzbl %dl,%edx
  8002ec:	83 c0 30             	add    $0x30,%eax
  8002ef:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  8002f3:	89 f2                	mov    %esi,%edx
    } while(*ap);
  8002f5:	84 db                	test   %bl,%bl
  8002f7:	75 d0                	jne    8002c9 <inet_ntoa+0x21>
  8002f9:	c6 07 00             	movb   $0x0,(%edi)
  8002fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002ff:	eb 0d                	jmp    80030e <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800301:	0f b6 c2             	movzbl %dl,%eax
  800304:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800309:	88 01                	mov    %al,(%ecx)
  80030b:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80030e:	83 ea 01             	sub    $0x1,%edx
  800311:	80 fa ff             	cmp    $0xff,%dl
  800314:	75 eb                	jne    800301 <inet_ntoa+0x59>
  800316:	89 f0                	mov    %esi,%eax
  800318:	0f b6 f0             	movzbl %al,%esi
  80031b:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  80031e:	8d 46 01             	lea    0x1(%esi),%eax
  800321:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800324:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  800327:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80032a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80032d:	39 c7                	cmp    %eax,%edi
  80032f:	75 90                	jne    8002c1 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800331:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800334:	b8 00 50 80 00       	mov    $0x805000,%eax
  800339:	83 c4 14             	add    $0x14,%esp
  80033c:	5b                   	pop    %ebx
  80033d:	5e                   	pop    %esi
  80033e:	5f                   	pop    %edi
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    

00800341 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800344:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800348:	66 c1 c0 08          	rol    $0x8,%ax
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800351:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800355:	66 c1 c0 08          	rol    $0x8,%ax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800361:	89 d1                	mov    %edx,%ecx
  800363:	c1 e1 18             	shl    $0x18,%ecx
  800366:	89 d0                	mov    %edx,%eax
  800368:	c1 e8 18             	shr    $0x18,%eax
  80036b:	09 c8                	or     %ecx,%eax
  80036d:	89 d1                	mov    %edx,%ecx
  80036f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800375:	c1 e1 08             	shl    $0x8,%ecx
  800378:	09 c8                	or     %ecx,%eax
  80037a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800380:	c1 ea 08             	shr    $0x8,%edx
  800383:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	57                   	push   %edi
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 20             	sub    $0x20,%esp
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800393:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800396:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800399:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80039c:	0f b6 ca             	movzbl %dl,%ecx
  80039f:	83 e9 30             	sub    $0x30,%ecx
  8003a2:	83 f9 09             	cmp    $0x9,%ecx
  8003a5:	0f 87 94 01 00 00    	ja     80053f <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8003ab:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8003b2:	83 fa 30             	cmp    $0x30,%edx
  8003b5:	75 2b                	jne    8003e2 <inet_aton+0x5b>
      c = *++cp;
  8003b7:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8003bb:	89 d1                	mov    %edx,%ecx
  8003bd:	83 e1 df             	and    $0xffffffdf,%ecx
  8003c0:	80 f9 58             	cmp    $0x58,%cl
  8003c3:	74 0f                	je     8003d4 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8003c5:	83 c0 01             	add    $0x1,%eax
  8003c8:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8003cb:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8003d2:	eb 0e                	jmp    8003e2 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8003d4:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8003d8:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8003db:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  8003e2:	83 c0 01             	add    $0x1,%eax
  8003e5:	be 00 00 00 00       	mov    $0x0,%esi
  8003ea:	eb 03                	jmp    8003ef <inet_aton+0x68>
  8003ec:	83 c0 01             	add    $0x1,%eax
  8003ef:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8003f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003f5:	0f b6 fa             	movzbl %dl,%edi
  8003f8:	8d 4f d0             	lea    -0x30(%edi),%ecx
  8003fb:	83 f9 09             	cmp    $0x9,%ecx
  8003fe:	77 0d                	ja     80040d <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800400:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800404:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800408:	0f be 10             	movsbl (%eax),%edx
  80040b:	eb df                	jmp    8003ec <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  80040d:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800411:	75 32                	jne    800445 <inet_aton+0xbe>
  800413:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800416:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800419:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041c:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800422:	83 e9 41             	sub    $0x41,%ecx
  800425:	83 f9 05             	cmp    $0x5,%ecx
  800428:	77 1b                	ja     800445 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  80042a:	c1 e6 04             	shl    $0x4,%esi
  80042d:	83 c2 0a             	add    $0xa,%edx
  800430:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800434:	19 c9                	sbb    %ecx,%ecx
  800436:	83 e1 20             	and    $0x20,%ecx
  800439:	83 c1 41             	add    $0x41,%ecx
  80043c:	29 ca                	sub    %ecx,%edx
  80043e:	09 d6                	or     %edx,%esi
        c = *++cp;
  800440:	0f be 10             	movsbl (%eax),%edx
  800443:	eb a7                	jmp    8003ec <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800445:	83 fa 2e             	cmp    $0x2e,%edx
  800448:	75 23                	jne    80046d <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80044a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80044d:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800450:	39 f8                	cmp    %edi,%eax
  800452:	0f 84 ee 00 00 00    	je     800546 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800458:	83 c0 04             	add    $0x4,%eax
  80045b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80045e:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800461:	8d 43 01             	lea    0x1(%ebx),%eax
  800464:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800468:	e9 2f ff ff ff       	jmp    80039c <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80046d:	85 d2                	test   %edx,%edx
  80046f:	74 25                	je     800496 <inet_aton+0x10f>
  800471:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800479:	83 f9 5f             	cmp    $0x5f,%ecx
  80047c:	0f 87 d0 00 00 00    	ja     800552 <inet_aton+0x1cb>
  800482:	83 fa 20             	cmp    $0x20,%edx
  800485:	74 0f                	je     800496 <inet_aton+0x10f>
  800487:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048a:	83 ea 09             	sub    $0x9,%edx
  80048d:	83 fa 04             	cmp    $0x4,%edx
  800490:	0f 87 bc 00 00 00    	ja     800552 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800496:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800499:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80049c:	29 c2                	sub    %eax,%edx
  80049e:	c1 fa 02             	sar    $0x2,%edx
  8004a1:	83 c2 01             	add    $0x1,%edx
  8004a4:	83 fa 02             	cmp    $0x2,%edx
  8004a7:	74 20                	je     8004c9 <inet_aton+0x142>
  8004a9:	83 fa 02             	cmp    $0x2,%edx
  8004ac:	7f 0f                	jg     8004bd <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	0f 84 97 00 00 00    	je     800552 <inet_aton+0x1cb>
  8004bb:	eb 67                	jmp    800524 <inet_aton+0x19d>
  8004bd:	83 fa 03             	cmp    $0x3,%edx
  8004c0:	74 1e                	je     8004e0 <inet_aton+0x159>
  8004c2:	83 fa 04             	cmp    $0x4,%edx
  8004c5:	74 38                	je     8004ff <inet_aton+0x178>
  8004c7:	eb 5b                	jmp    800524 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8004c9:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8004ce:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8004d4:	77 7c                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8004d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d9:	c1 e0 18             	shl    $0x18,%eax
  8004dc:	09 c6                	or     %eax,%esi
    break;
  8004de:	eb 44                	jmp    800524 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8004e0:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  8004e5:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  8004eb:	77 65                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8004ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f0:	c1 e2 18             	shl    $0x18,%edx
  8004f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8004f6:	c1 e0 10             	shl    $0x10,%eax
  8004f9:	09 d0                	or     %edx,%eax
  8004fb:	09 c6                	or     %eax,%esi
    break;
  8004fd:	eb 25                	jmp    800524 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800504:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  80050a:	77 46                	ja     800552 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80050c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050f:	c1 e2 18             	shl    $0x18,%edx
  800512:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800515:	c1 e0 10             	shl    $0x10,%eax
  800518:	09 c2                	or     %eax,%edx
  80051a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80051d:	c1 e0 08             	shl    $0x8,%eax
  800520:	09 d0                	or     %edx,%eax
  800522:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800524:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800528:	74 23                	je     80054d <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  80052a:	56                   	push   %esi
  80052b:	e8 2b fe ff ff       	call   80035b <htonl>
  800530:	83 c4 04             	add    $0x4,%esp
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	89 03                	mov    %eax,(%ebx)
  return (1);
  800538:	b8 01 00 00 00       	mov    $0x1,%eax
  80053d:	eb 13                	jmp    800552 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80053f:	b8 00 00 00 00       	mov    $0x0,%eax
  800544:	eb 0c                	jmp    800552 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	eb 05                	jmp    800552 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80054d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800552:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800555:	5b                   	pop    %ebx
  800556:	5e                   	pop    %esi
  800557:	5f                   	pop    %edi
  800558:	5d                   	pop    %ebp
  800559:	c3                   	ret    

0080055a <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800560:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800563:	50                   	push   %eax
  800564:	ff 75 08             	pushl  0x8(%ebp)
  800567:	e8 1b fe ff ff       	call   800387 <inet_aton>
  80056c:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80056f:	85 c0                	test   %eax,%eax
  800571:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800576:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80057f:	ff 75 08             	pushl  0x8(%ebp)
  800582:	e8 d4 fd ff ff       	call   80035b <htonl>
  800587:	83 c4 04             	add    $0x4,%esp
}
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    

0080058c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	56                   	push   %esi
  800590:	53                   	push   %ebx
  800591:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800594:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800597:	e8 73 0a 00 00       	call   80100f <sys_getenvid>
  80059c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005a9:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	7e 07                	jle    8005b9 <libmain+0x2d>
		binaryname = argv[0];
  8005b2:	8b 06                	mov    (%esi),%eax
  8005b4:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	56                   	push   %esi
  8005bd:	53                   	push   %ebx
  8005be:	e8 04 fc ff ff       	call   8001c7 <umain>

	// exit gracefully
	exit();
  8005c3:	e8 0a 00 00 00       	call   8005d2 <exit>
}
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005ce:	5b                   	pop    %ebx
  8005cf:	5e                   	pop    %esi
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005d8:	e8 4b 0e 00 00       	call   801428 <close_all>
	sys_env_destroy(0);
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	6a 00                	push   $0x0
  8005e2:	e8 e7 09 00 00       	call   800fce <sys_env_destroy>
}
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	c9                   	leave  
  8005eb:	c3                   	ret    

008005ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	56                   	push   %esi
  8005f0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f4:	8b 35 20 40 80 00    	mov    0x804020,%esi
  8005fa:	e8 10 0a 00 00       	call   80100f <sys_getenvid>
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	ff 75 0c             	pushl  0xc(%ebp)
  800605:	ff 75 08             	pushl  0x8(%ebp)
  800608:	56                   	push   %esi
  800609:	50                   	push   %eax
  80060a:	68 b0 2b 80 00       	push   $0x802bb0
  80060f:	e8 b1 00 00 00       	call   8006c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800614:	83 c4 18             	add    $0x18,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 10             	pushl  0x10(%ebp)
  80061b:	e8 54 00 00 00       	call   800674 <vcprintf>
	cprintf("\n");
  800620:	c7 04 24 e7 2f 80 00 	movl   $0x802fe7,(%esp)
  800627:	e8 99 00 00 00       	call   8006c5 <cprintf>
  80062c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062f:	cc                   	int3   
  800630:	eb fd                	jmp    80062f <_panic+0x43>

00800632 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	53                   	push   %ebx
  800636:	83 ec 04             	sub    $0x4,%esp
  800639:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063c:	8b 13                	mov    (%ebx),%edx
  80063e:	8d 42 01             	lea    0x1(%edx),%eax
  800641:	89 03                	mov    %eax,(%ebx)
  800643:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800646:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064f:	75 1a                	jne    80066b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	68 ff 00 00 00       	push   $0xff
  800659:	8d 43 08             	lea    0x8(%ebx),%eax
  80065c:	50                   	push   %eax
  80065d:	e8 2f 09 00 00       	call   800f91 <sys_cputs>
		b->idx = 0;
  800662:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800668:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80066b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80066f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800672:	c9                   	leave  
  800673:	c3                   	ret    

00800674 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80067d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800684:	00 00 00 
	b.cnt = 0;
  800687:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80068e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800691:	ff 75 0c             	pushl  0xc(%ebp)
  800694:	ff 75 08             	pushl  0x8(%ebp)
  800697:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80069d:	50                   	push   %eax
  80069e:	68 32 06 80 00       	push   $0x800632
  8006a3:	e8 54 01 00 00       	call   8007fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a8:	83 c4 08             	add    $0x8,%esp
  8006ab:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b7:	50                   	push   %eax
  8006b8:	e8 d4 08 00 00       	call   800f91 <sys_cputs>

	return b.cnt;
}
  8006bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006ce:	50                   	push   %eax
  8006cf:	ff 75 08             	pushl  0x8(%ebp)
  8006d2:	e8 9d ff ff ff       	call   800674 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	57                   	push   %edi
  8006dd:	56                   	push   %esi
  8006de:	53                   	push   %ebx
  8006df:	83 ec 1c             	sub    $0x1c,%esp
  8006e2:	89 c7                	mov    %eax,%edi
  8006e4:	89 d6                	mov    %edx,%esi
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800700:	39 d3                	cmp    %edx,%ebx
  800702:	72 05                	jb     800709 <printnum+0x30>
  800704:	39 45 10             	cmp    %eax,0x10(%ebp)
  800707:	77 45                	ja     80074e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	ff 75 18             	pushl  0x18(%ebp)
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800715:	53                   	push   %ebx
  800716:	ff 75 10             	pushl  0x10(%ebp)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071f:	ff 75 e0             	pushl  -0x20(%ebp)
  800722:	ff 75 dc             	pushl  -0x24(%ebp)
  800725:	ff 75 d8             	pushl  -0x28(%ebp)
  800728:	e8 33 20 00 00       	call   802760 <__udivdi3>
  80072d:	83 c4 18             	add    $0x18,%esp
  800730:	52                   	push   %edx
  800731:	50                   	push   %eax
  800732:	89 f2                	mov    %esi,%edx
  800734:	89 f8                	mov    %edi,%eax
  800736:	e8 9e ff ff ff       	call   8006d9 <printnum>
  80073b:	83 c4 20             	add    $0x20,%esp
  80073e:	eb 18                	jmp    800758 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	56                   	push   %esi
  800744:	ff 75 18             	pushl  0x18(%ebp)
  800747:	ff d7                	call   *%edi
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 03                	jmp    800751 <printnum+0x78>
  80074e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800751:	83 eb 01             	sub    $0x1,%ebx
  800754:	85 db                	test   %ebx,%ebx
  800756:	7f e8                	jg     800740 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	56                   	push   %esi
  80075c:	83 ec 04             	sub    $0x4,%esp
  80075f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800762:	ff 75 e0             	pushl  -0x20(%ebp)
  800765:	ff 75 dc             	pushl  -0x24(%ebp)
  800768:	ff 75 d8             	pushl  -0x28(%ebp)
  80076b:	e8 20 21 00 00       	call   802890 <__umoddi3>
  800770:	83 c4 14             	add    $0x14,%esp
  800773:	0f be 80 d3 2b 80 00 	movsbl 0x802bd3(%eax),%eax
  80077a:	50                   	push   %eax
  80077b:	ff d7                	call   *%edi
}
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5f                   	pop    %edi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078b:	83 fa 01             	cmp    $0x1,%edx
  80078e:	7e 0e                	jle    80079e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800790:	8b 10                	mov    (%eax),%edx
  800792:	8d 4a 08             	lea    0x8(%edx),%ecx
  800795:	89 08                	mov    %ecx,(%eax)
  800797:	8b 02                	mov    (%edx),%eax
  800799:	8b 52 04             	mov    0x4(%edx),%edx
  80079c:	eb 22                	jmp    8007c0 <getuint+0x38>
	else if (lflag)
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 10                	je     8007b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 02                	mov    (%edx),%eax
  8007ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b0:	eb 0e                	jmp    8007c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b2:	8b 10                	mov    (%eax),%edx
  8007b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b7:	89 08                	mov    %ecx,(%eax)
  8007b9:	8b 02                	mov    (%edx),%eax
  8007bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007cc:	8b 10                	mov    (%eax),%edx
  8007ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d1:	73 0a                	jae    8007dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d6:	89 08                	mov    %ecx,(%eax)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	88 02                	mov    %al,(%edx)
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e8:	50                   	push   %eax
  8007e9:	ff 75 10             	pushl  0x10(%ebp)
  8007ec:	ff 75 0c             	pushl  0xc(%ebp)
  8007ef:	ff 75 08             	pushl  0x8(%ebp)
  8007f2:	e8 05 00 00 00       	call   8007fc <vprintfmt>
	va_end(ap);
}
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	57                   	push   %edi
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	83 ec 2c             	sub    $0x2c,%esp
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80080e:	eb 12                	jmp    800822 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800810:	85 c0                	test   %eax,%eax
  800812:	0f 84 89 03 00 00    	je     800ba1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	50                   	push   %eax
  80081d:	ff d6                	call   *%esi
  80081f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800822:	83 c7 01             	add    $0x1,%edi
  800825:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800829:	83 f8 25             	cmp    $0x25,%eax
  80082c:	75 e2                	jne    800810 <vprintfmt+0x14>
  80082e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800832:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800839:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800840:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 07                	jmp    800855 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800851:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8d 47 01             	lea    0x1(%edi),%eax
  800858:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085b:	0f b6 07             	movzbl (%edi),%eax
  80085e:	0f b6 c8             	movzbl %al,%ecx
  800861:	83 e8 23             	sub    $0x23,%eax
  800864:	3c 55                	cmp    $0x55,%al
  800866:	0f 87 1a 03 00 00    	ja     800b86 <vprintfmt+0x38a>
  80086c:	0f b6 c0             	movzbl %al,%eax
  80086f:	ff 24 85 20 2d 80 00 	jmp    *0x802d20(,%eax,4)
  800876:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800879:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80087d:	eb d6                	jmp    800855 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80088d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800891:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800894:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800897:	83 fa 09             	cmp    $0x9,%edx
  80089a:	77 39                	ja     8008d5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80089c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80089f:	eb e9                	jmp    80088a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8d 48 04             	lea    0x4(%eax),%ecx
  8008a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b2:	eb 27                	jmp    8008db <vprintfmt+0xdf>
  8008b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008be:	0f 49 c8             	cmovns %eax,%ecx
  8008c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c7:	eb 8c                	jmp    800855 <vprintfmt+0x59>
  8008c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d3:	eb 80                	jmp    800855 <vprintfmt+0x59>
  8008d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008d8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008df:	0f 89 70 ff ff ff    	jns    800855 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f2:	e9 5e ff ff ff       	jmp    800855 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008fd:	e9 53 ff ff ff       	jmp    800855 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 50 04             	lea    0x4(%eax),%edx
  800908:	89 55 14             	mov    %edx,0x14(%ebp)
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	53                   	push   %ebx
  80090f:	ff 30                	pushl  (%eax)
  800911:	ff d6                	call   *%esi
			break;
  800913:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800916:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800919:	e9 04 ff ff ff       	jmp    800822 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80091e:	8b 45 14             	mov    0x14(%ebp),%eax
  800921:	8d 50 04             	lea    0x4(%eax),%edx
  800924:	89 55 14             	mov    %edx,0x14(%ebp)
  800927:	8b 00                	mov    (%eax),%eax
  800929:	99                   	cltd   
  80092a:	31 d0                	xor    %edx,%eax
  80092c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092e:	83 f8 0f             	cmp    $0xf,%eax
  800931:	7f 0b                	jg     80093e <vprintfmt+0x142>
  800933:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  80093a:	85 d2                	test   %edx,%edx
  80093c:	75 18                	jne    800956 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80093e:	50                   	push   %eax
  80093f:	68 eb 2b 80 00       	push   $0x802beb
  800944:	53                   	push   %ebx
  800945:	56                   	push   %esi
  800946:	e8 94 fe ff ff       	call   8007df <printfmt>
  80094b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800951:	e9 cc fe ff ff       	jmp    800822 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800956:	52                   	push   %edx
  800957:	68 b5 2f 80 00       	push   $0x802fb5
  80095c:	53                   	push   %ebx
  80095d:	56                   	push   %esi
  80095e:	e8 7c fe ff ff       	call   8007df <printfmt>
  800963:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800969:	e9 b4 fe ff ff       	jmp    800822 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80096e:	8b 45 14             	mov    0x14(%ebp),%eax
  800971:	8d 50 04             	lea    0x4(%eax),%edx
  800974:	89 55 14             	mov    %edx,0x14(%ebp)
  800977:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800979:	85 ff                	test   %edi,%edi
  80097b:	b8 e4 2b 80 00       	mov    $0x802be4,%eax
  800980:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800983:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800987:	0f 8e 94 00 00 00    	jle    800a21 <vprintfmt+0x225>
  80098d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800991:	0f 84 98 00 00 00    	je     800a2f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	ff 75 d0             	pushl  -0x30(%ebp)
  80099d:	57                   	push   %edi
  80099e:	e8 86 02 00 00       	call   800c29 <strnlen>
  8009a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009a6:	29 c1                	sub    %eax,%ecx
  8009a8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009ab:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009ae:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009b8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ba:	eb 0f                	jmp    8009cb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009bc:	83 ec 08             	sub    $0x8,%esp
  8009bf:	53                   	push   %ebx
  8009c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c5:	83 ef 01             	sub    $0x1,%edi
  8009c8:	83 c4 10             	add    $0x10,%esp
  8009cb:	85 ff                	test   %edi,%edi
  8009cd:	7f ed                	jg     8009bc <vprintfmt+0x1c0>
  8009cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009d5:	85 c9                	test   %ecx,%ecx
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	0f 49 c1             	cmovns %ecx,%eax
  8009df:	29 c1                	sub    %eax,%ecx
  8009e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ea:	89 cb                	mov    %ecx,%ebx
  8009ec:	eb 4d                	jmp    800a3b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f2:	74 1b                	je     800a0f <vprintfmt+0x213>
  8009f4:	0f be c0             	movsbl %al,%eax
  8009f7:	83 e8 20             	sub    $0x20,%eax
  8009fa:	83 f8 5e             	cmp    $0x5e,%eax
  8009fd:	76 10                	jbe    800a0f <vprintfmt+0x213>
					putch('?', putdat);
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	6a 3f                	push   $0x3f
  800a07:	ff 55 08             	call   *0x8(%ebp)
  800a0a:	83 c4 10             	add    $0x10,%esp
  800a0d:	eb 0d                	jmp    800a1c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	52                   	push   %edx
  800a16:	ff 55 08             	call   *0x8(%ebp)
  800a19:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1c:	83 eb 01             	sub    $0x1,%ebx
  800a1f:	eb 1a                	jmp    800a3b <vprintfmt+0x23f>
  800a21:	89 75 08             	mov    %esi,0x8(%ebp)
  800a24:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a27:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a2a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a2d:	eb 0c                	jmp    800a3b <vprintfmt+0x23f>
  800a2f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a32:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a35:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a38:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3b:	83 c7 01             	add    $0x1,%edi
  800a3e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a42:	0f be d0             	movsbl %al,%edx
  800a45:	85 d2                	test   %edx,%edx
  800a47:	74 23                	je     800a6c <vprintfmt+0x270>
  800a49:	85 f6                	test   %esi,%esi
  800a4b:	78 a1                	js     8009ee <vprintfmt+0x1f2>
  800a4d:	83 ee 01             	sub    $0x1,%esi
  800a50:	79 9c                	jns    8009ee <vprintfmt+0x1f2>
  800a52:	89 df                	mov    %ebx,%edi
  800a54:	8b 75 08             	mov    0x8(%ebp),%esi
  800a57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5a:	eb 18                	jmp    800a74 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	53                   	push   %ebx
  800a60:	6a 20                	push   $0x20
  800a62:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a64:	83 ef 01             	sub    $0x1,%edi
  800a67:	83 c4 10             	add    $0x10,%esp
  800a6a:	eb 08                	jmp    800a74 <vprintfmt+0x278>
  800a6c:	89 df                	mov    %ebx,%edi
  800a6e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a74:	85 ff                	test   %edi,%edi
  800a76:	7f e4                	jg     800a5c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7b:	e9 a2 fd ff ff       	jmp    800822 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a80:	83 fa 01             	cmp    $0x1,%edx
  800a83:	7e 16                	jle    800a9b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	8d 50 08             	lea    0x8(%eax),%edx
  800a8b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8e:	8b 50 04             	mov    0x4(%eax),%edx
  800a91:	8b 00                	mov    (%eax),%eax
  800a93:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a96:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a99:	eb 32                	jmp    800acd <vprintfmt+0x2d1>
	else if (lflag)
  800a9b:	85 d2                	test   %edx,%edx
  800a9d:	74 18                	je     800ab7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800a9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa2:	8d 50 04             	lea    0x4(%eax),%edx
  800aa5:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa8:	8b 00                	mov    (%eax),%eax
  800aaa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aad:	89 c1                	mov    %eax,%ecx
  800aaf:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ab5:	eb 16                	jmp    800acd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ab7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aba:	8d 50 04             	lea    0x4(%eax),%edx
  800abd:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac0:	8b 00                	mov    (%eax),%eax
  800ac2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac5:	89 c1                	mov    %eax,%ecx
  800ac7:	c1 f9 1f             	sar    $0x1f,%ecx
  800aca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800acd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ad8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800adc:	79 74                	jns    800b52 <vprintfmt+0x356>
				putch('-', putdat);
  800ade:	83 ec 08             	sub    $0x8,%esp
  800ae1:	53                   	push   %ebx
  800ae2:	6a 2d                	push   $0x2d
  800ae4:	ff d6                	call   *%esi
				num = -(long long) num;
  800ae6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ae9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800aec:	f7 d8                	neg    %eax
  800aee:	83 d2 00             	adc    $0x0,%edx
  800af1:	f7 da                	neg    %edx
  800af3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800af6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800afb:	eb 55                	jmp    800b52 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800afd:	8d 45 14             	lea    0x14(%ebp),%eax
  800b00:	e8 83 fc ff ff       	call   800788 <getuint>
			base = 10;
  800b05:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b0a:	eb 46                	jmp    800b52 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800b0c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0f:	e8 74 fc ff ff       	call   800788 <getuint>
			base = 8;
  800b14:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b19:	eb 37                	jmp    800b52 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	53                   	push   %ebx
  800b1f:	6a 30                	push   $0x30
  800b21:	ff d6                	call   *%esi
			putch('x', putdat);
  800b23:	83 c4 08             	add    $0x8,%esp
  800b26:	53                   	push   %ebx
  800b27:	6a 78                	push   $0x78
  800b29:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8d 50 04             	lea    0x4(%eax),%edx
  800b31:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b34:	8b 00                	mov    (%eax),%eax
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b3b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b3e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b43:	eb 0d                	jmp    800b52 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b45:	8d 45 14             	lea    0x14(%ebp),%eax
  800b48:	e8 3b fc ff ff       	call   800788 <getuint>
			base = 16;
  800b4d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b59:	57                   	push   %edi
  800b5a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b5d:	51                   	push   %ecx
  800b5e:	52                   	push   %edx
  800b5f:	50                   	push   %eax
  800b60:	89 da                	mov    %ebx,%edx
  800b62:	89 f0                	mov    %esi,%eax
  800b64:	e8 70 fb ff ff       	call   8006d9 <printnum>
			break;
  800b69:	83 c4 20             	add    $0x20,%esp
  800b6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b6f:	e9 ae fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b74:	83 ec 08             	sub    $0x8,%esp
  800b77:	53                   	push   %ebx
  800b78:	51                   	push   %ecx
  800b79:	ff d6                	call   *%esi
			break;
  800b7b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b81:	e9 9c fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b86:	83 ec 08             	sub    $0x8,%esp
  800b89:	53                   	push   %ebx
  800b8a:	6a 25                	push   $0x25
  800b8c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	eb 03                	jmp    800b96 <vprintfmt+0x39a>
  800b93:	83 ef 01             	sub    $0x1,%edi
  800b96:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b9a:	75 f7                	jne    800b93 <vprintfmt+0x397>
  800b9c:	e9 81 fc ff ff       	jmp    800822 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	83 ec 18             	sub    $0x18,%esp
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bb8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bbc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	74 26                	je     800bf0 <vsnprintf+0x47>
  800bca:	85 d2                	test   %edx,%edx
  800bcc:	7e 22                	jle    800bf0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bce:	ff 75 14             	pushl  0x14(%ebp)
  800bd1:	ff 75 10             	pushl  0x10(%ebp)
  800bd4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bd7:	50                   	push   %eax
  800bd8:	68 c2 07 80 00       	push   $0x8007c2
  800bdd:	e8 1a fc ff ff       	call   8007fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800beb:	83 c4 10             	add    $0x10,%esp
  800bee:	eb 05                	jmp    800bf5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bf5:	c9                   	leave  
  800bf6:	c3                   	ret    

00800bf7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bfd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c00:	50                   	push   %eax
  800c01:	ff 75 10             	pushl  0x10(%ebp)
  800c04:	ff 75 0c             	pushl  0xc(%ebp)
  800c07:	ff 75 08             	pushl  0x8(%ebp)
  800c0a:	e8 9a ff ff ff       	call   800ba9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c17:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1c:	eb 03                	jmp    800c21 <strlen+0x10>
		n++;
  800c1e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c21:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c25:	75 f7                	jne    800c1e <strlen+0xd>
		n++;
	return n;
}
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	eb 03                	jmp    800c3c <strnlen+0x13>
		n++;
  800c39:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3c:	39 c2                	cmp    %eax,%edx
  800c3e:	74 08                	je     800c48 <strnlen+0x1f>
  800c40:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c44:	75 f3                	jne    800c39 <strnlen+0x10>
  800c46:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	53                   	push   %ebx
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c54:	89 c2                	mov    %eax,%edx
  800c56:	83 c2 01             	add    $0x1,%edx
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c60:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c63:	84 db                	test   %bl,%bl
  800c65:	75 ef                	jne    800c56 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c67:	5b                   	pop    %ebx
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	53                   	push   %ebx
  800c6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c71:	53                   	push   %ebx
  800c72:	e8 9a ff ff ff       	call   800c11 <strlen>
  800c77:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c7a:	ff 75 0c             	pushl  0xc(%ebp)
  800c7d:	01 d8                	add    %ebx,%eax
  800c7f:	50                   	push   %eax
  800c80:	e8 c5 ff ff ff       	call   800c4a <strcpy>
	return dst;
}
  800c85:	89 d8                	mov    %ebx,%eax
  800c87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    

00800c8c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	8b 75 08             	mov    0x8(%ebp),%esi
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	89 f3                	mov    %esi,%ebx
  800c99:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9c:	89 f2                	mov    %esi,%edx
  800c9e:	eb 0f                	jmp    800caf <strncpy+0x23>
		*dst++ = *src;
  800ca0:	83 c2 01             	add    $0x1,%edx
  800ca3:	0f b6 01             	movzbl (%ecx),%eax
  800ca6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ca9:	80 39 01             	cmpb   $0x1,(%ecx)
  800cac:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800caf:	39 da                	cmp    %ebx,%edx
  800cb1:	75 ed                	jne    800ca0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb3:	89 f0                	mov    %esi,%eax
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 10             	mov    0x10(%ebp),%edx
  800cc7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc9:	85 d2                	test   %edx,%edx
  800ccb:	74 21                	je     800cee <strlcpy+0x35>
  800ccd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cd1:	89 f2                	mov    %esi,%edx
  800cd3:	eb 09                	jmp    800cde <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cd5:	83 c2 01             	add    $0x1,%edx
  800cd8:	83 c1 01             	add    $0x1,%ecx
  800cdb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cde:	39 c2                	cmp    %eax,%edx
  800ce0:	74 09                	je     800ceb <strlcpy+0x32>
  800ce2:	0f b6 19             	movzbl (%ecx),%ebx
  800ce5:	84 db                	test   %bl,%bl
  800ce7:	75 ec                	jne    800cd5 <strlcpy+0x1c>
  800ce9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ceb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cee:	29 f0                	sub    %esi,%eax
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cfd:	eb 06                	jmp    800d05 <strcmp+0x11>
		p++, q++;
  800cff:	83 c1 01             	add    $0x1,%ecx
  800d02:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d05:	0f b6 01             	movzbl (%ecx),%eax
  800d08:	84 c0                	test   %al,%al
  800d0a:	74 04                	je     800d10 <strcmp+0x1c>
  800d0c:	3a 02                	cmp    (%edx),%al
  800d0e:	74 ef                	je     800cff <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d10:	0f b6 c0             	movzbl %al,%eax
  800d13:	0f b6 12             	movzbl (%edx),%edx
  800d16:	29 d0                	sub    %edx,%eax
}
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	53                   	push   %ebx
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d24:	89 c3                	mov    %eax,%ebx
  800d26:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d29:	eb 06                	jmp    800d31 <strncmp+0x17>
		n--, p++, q++;
  800d2b:	83 c0 01             	add    $0x1,%eax
  800d2e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d31:	39 d8                	cmp    %ebx,%eax
  800d33:	74 15                	je     800d4a <strncmp+0x30>
  800d35:	0f b6 08             	movzbl (%eax),%ecx
  800d38:	84 c9                	test   %cl,%cl
  800d3a:	74 04                	je     800d40 <strncmp+0x26>
  800d3c:	3a 0a                	cmp    (%edx),%cl
  800d3e:	74 eb                	je     800d2b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d40:	0f b6 00             	movzbl (%eax),%eax
  800d43:	0f b6 12             	movzbl (%edx),%edx
  800d46:	29 d0                	sub    %edx,%eax
  800d48:	eb 05                	jmp    800d4f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d4a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	8b 45 08             	mov    0x8(%ebp),%eax
  800d58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d5c:	eb 07                	jmp    800d65 <strchr+0x13>
		if (*s == c)
  800d5e:	38 ca                	cmp    %cl,%dl
  800d60:	74 0f                	je     800d71 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d62:	83 c0 01             	add    $0x1,%eax
  800d65:	0f b6 10             	movzbl (%eax),%edx
  800d68:	84 d2                	test   %dl,%dl
  800d6a:	75 f2                	jne    800d5e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d7d:	eb 03                	jmp    800d82 <strfind+0xf>
  800d7f:	83 c0 01             	add    $0x1,%eax
  800d82:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d85:	38 ca                	cmp    %cl,%dl
  800d87:	74 04                	je     800d8d <strfind+0x1a>
  800d89:	84 d2                	test   %dl,%dl
  800d8b:	75 f2                	jne    800d7f <strfind+0xc>
			break;
	return (char *) s;
}
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d98:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d9b:	85 c9                	test   %ecx,%ecx
  800d9d:	74 36                	je     800dd5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d9f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da5:	75 28                	jne    800dcf <memset+0x40>
  800da7:	f6 c1 03             	test   $0x3,%cl
  800daa:	75 23                	jne    800dcf <memset+0x40>
		c &= 0xFF;
  800dac:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db0:	89 d3                	mov    %edx,%ebx
  800db2:	c1 e3 08             	shl    $0x8,%ebx
  800db5:	89 d6                	mov    %edx,%esi
  800db7:	c1 e6 18             	shl    $0x18,%esi
  800dba:	89 d0                	mov    %edx,%eax
  800dbc:	c1 e0 10             	shl    $0x10,%eax
  800dbf:	09 f0                	or     %esi,%eax
  800dc1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dc3:	89 d8                	mov    %ebx,%eax
  800dc5:	09 d0                	or     %edx,%eax
  800dc7:	c1 e9 02             	shr    $0x2,%ecx
  800dca:	fc                   	cld    
  800dcb:	f3 ab                	rep stos %eax,%es:(%edi)
  800dcd:	eb 06                	jmp    800dd5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd2:	fc                   	cld    
  800dd3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd5:	89 f8                	mov    %edi,%eax
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dea:	39 c6                	cmp    %eax,%esi
  800dec:	73 35                	jae    800e23 <memmove+0x47>
  800dee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df1:	39 d0                	cmp    %edx,%eax
  800df3:	73 2e                	jae    800e23 <memmove+0x47>
		s += n;
		d += n;
  800df5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df8:	89 d6                	mov    %edx,%esi
  800dfa:	09 fe                	or     %edi,%esi
  800dfc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e02:	75 13                	jne    800e17 <memmove+0x3b>
  800e04:	f6 c1 03             	test   $0x3,%cl
  800e07:	75 0e                	jne    800e17 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e09:	83 ef 04             	sub    $0x4,%edi
  800e0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e0f:	c1 e9 02             	shr    $0x2,%ecx
  800e12:	fd                   	std    
  800e13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e15:	eb 09                	jmp    800e20 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e17:	83 ef 01             	sub    $0x1,%edi
  800e1a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e1d:	fd                   	std    
  800e1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e20:	fc                   	cld    
  800e21:	eb 1d                	jmp    800e40 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e23:	89 f2                	mov    %esi,%edx
  800e25:	09 c2                	or     %eax,%edx
  800e27:	f6 c2 03             	test   $0x3,%dl
  800e2a:	75 0f                	jne    800e3b <memmove+0x5f>
  800e2c:	f6 c1 03             	test   $0x3,%cl
  800e2f:	75 0a                	jne    800e3b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e31:	c1 e9 02             	shr    $0x2,%ecx
  800e34:	89 c7                	mov    %eax,%edi
  800e36:	fc                   	cld    
  800e37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e39:	eb 05                	jmp    800e40 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e3b:	89 c7                	mov    %eax,%edi
  800e3d:	fc                   	cld    
  800e3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e47:	ff 75 10             	pushl  0x10(%ebp)
  800e4a:	ff 75 0c             	pushl  0xc(%ebp)
  800e4d:	ff 75 08             	pushl  0x8(%ebp)
  800e50:	e8 87 ff ff ff       	call   800ddc <memmove>
}
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    

00800e57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e62:	89 c6                	mov    %eax,%esi
  800e64:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e67:	eb 1a                	jmp    800e83 <memcmp+0x2c>
		if (*s1 != *s2)
  800e69:	0f b6 08             	movzbl (%eax),%ecx
  800e6c:	0f b6 1a             	movzbl (%edx),%ebx
  800e6f:	38 d9                	cmp    %bl,%cl
  800e71:	74 0a                	je     800e7d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e73:	0f b6 c1             	movzbl %cl,%eax
  800e76:	0f b6 db             	movzbl %bl,%ebx
  800e79:	29 d8                	sub    %ebx,%eax
  800e7b:	eb 0f                	jmp    800e8c <memcmp+0x35>
		s1++, s2++;
  800e7d:	83 c0 01             	add    $0x1,%eax
  800e80:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e83:	39 f0                	cmp    %esi,%eax
  800e85:	75 e2                	jne    800e69 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	53                   	push   %ebx
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e97:	89 c1                	mov    %eax,%ecx
  800e99:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800e9c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea0:	eb 0a                	jmp    800eac <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea2:	0f b6 10             	movzbl (%eax),%edx
  800ea5:	39 da                	cmp    %ebx,%edx
  800ea7:	74 07                	je     800eb0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea9:	83 c0 01             	add    $0x1,%eax
  800eac:	39 c8                	cmp    %ecx,%eax
  800eae:	72 f2                	jb     800ea2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ebf:	eb 03                	jmp    800ec4 <strtol+0x11>
		s++;
  800ec1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec4:	0f b6 01             	movzbl (%ecx),%eax
  800ec7:	3c 20                	cmp    $0x20,%al
  800ec9:	74 f6                	je     800ec1 <strtol+0xe>
  800ecb:	3c 09                	cmp    $0x9,%al
  800ecd:	74 f2                	je     800ec1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ecf:	3c 2b                	cmp    $0x2b,%al
  800ed1:	75 0a                	jne    800edd <strtol+0x2a>
		s++;
  800ed3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed6:	bf 00 00 00 00       	mov    $0x0,%edi
  800edb:	eb 11                	jmp    800eee <strtol+0x3b>
  800edd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee2:	3c 2d                	cmp    $0x2d,%al
  800ee4:	75 08                	jne    800eee <strtol+0x3b>
		s++, neg = 1;
  800ee6:	83 c1 01             	add    $0x1,%ecx
  800ee9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eee:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ef4:	75 15                	jne    800f0b <strtol+0x58>
  800ef6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ef9:	75 10                	jne    800f0b <strtol+0x58>
  800efb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800eff:	75 7c                	jne    800f7d <strtol+0xca>
		s += 2, base = 16;
  800f01:	83 c1 02             	add    $0x2,%ecx
  800f04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f09:	eb 16                	jmp    800f21 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f0b:	85 db                	test   %ebx,%ebx
  800f0d:	75 12                	jne    800f21 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f0f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f14:	80 39 30             	cmpb   $0x30,(%ecx)
  800f17:	75 08                	jne    800f21 <strtol+0x6e>
		s++, base = 8;
  800f19:	83 c1 01             	add    $0x1,%ecx
  800f1c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
  800f26:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f29:	0f b6 11             	movzbl (%ecx),%edx
  800f2c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f2f:	89 f3                	mov    %esi,%ebx
  800f31:	80 fb 09             	cmp    $0x9,%bl
  800f34:	77 08                	ja     800f3e <strtol+0x8b>
			dig = *s - '0';
  800f36:	0f be d2             	movsbl %dl,%edx
  800f39:	83 ea 30             	sub    $0x30,%edx
  800f3c:	eb 22                	jmp    800f60 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f3e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f41:	89 f3                	mov    %esi,%ebx
  800f43:	80 fb 19             	cmp    $0x19,%bl
  800f46:	77 08                	ja     800f50 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f48:	0f be d2             	movsbl %dl,%edx
  800f4b:	83 ea 57             	sub    $0x57,%edx
  800f4e:	eb 10                	jmp    800f60 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f50:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f53:	89 f3                	mov    %esi,%ebx
  800f55:	80 fb 19             	cmp    $0x19,%bl
  800f58:	77 16                	ja     800f70 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f5a:	0f be d2             	movsbl %dl,%edx
  800f5d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f60:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f63:	7d 0b                	jge    800f70 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f65:	83 c1 01             	add    $0x1,%ecx
  800f68:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f6c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f6e:	eb b9                	jmp    800f29 <strtol+0x76>

	if (endptr)
  800f70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f74:	74 0d                	je     800f83 <strtol+0xd0>
		*endptr = (char *) s;
  800f76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f79:	89 0e                	mov    %ecx,(%esi)
  800f7b:	eb 06                	jmp    800f83 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f7d:	85 db                	test   %ebx,%ebx
  800f7f:	74 98                	je     800f19 <strtol+0x66>
  800f81:	eb 9e                	jmp    800f21 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f83:	89 c2                	mov    %eax,%edx
  800f85:	f7 da                	neg    %edx
  800f87:	85 ff                	test   %edi,%edi
  800f89:	0f 45 c2             	cmovne %edx,%eax
}
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	57                   	push   %edi
  800f95:	56                   	push   %esi
  800f96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f97:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	89 c7                	mov    %eax,%edi
  800fa6:	89 c6                	mov    %eax,%esi
  800fa8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    

00800faf <sys_cgetc>:

int
sys_cgetc(void)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fba:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbf:	89 d1                	mov    %edx,%ecx
  800fc1:	89 d3                	mov    %edx,%ebx
  800fc3:	89 d7                	mov    %edx,%edi
  800fc5:	89 d6                	mov    %edx,%esi
  800fc7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdc:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe4:	89 cb                	mov    %ecx,%ebx
  800fe6:	89 cf                	mov    %ecx,%edi
  800fe8:	89 ce                	mov    %ecx,%esi
  800fea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fec:	85 c0                	test   %eax,%eax
  800fee:	7e 17                	jle    801007 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	50                   	push   %eax
  800ff4:	6a 03                	push   $0x3
  800ff6:	68 df 2e 80 00       	push   $0x802edf
  800ffb:	6a 23                	push   $0x23
  800ffd:	68 fc 2e 80 00       	push   $0x802efc
  801002:	e8 e5 f5 ff ff       	call   8005ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100a:	5b                   	pop    %ebx
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	57                   	push   %edi
  801013:	56                   	push   %esi
  801014:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	ba 00 00 00 00       	mov    $0x0,%edx
  80101a:	b8 02 00 00 00       	mov    $0x2,%eax
  80101f:	89 d1                	mov    %edx,%ecx
  801021:	89 d3                	mov    %edx,%ebx
  801023:	89 d7                	mov    %edx,%edi
  801025:	89 d6                	mov    %edx,%esi
  801027:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5f                   	pop    %edi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sys_yield>:

void
sys_yield(void)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801034:	ba 00 00 00 00       	mov    $0x0,%edx
  801039:	b8 0b 00 00 00       	mov    $0xb,%eax
  80103e:	89 d1                	mov    %edx,%ecx
  801040:	89 d3                	mov    %edx,%ebx
  801042:	89 d7                	mov    %edx,%edi
  801044:	89 d6                	mov    %edx,%esi
  801046:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	5d                   	pop    %ebp
  80104c:	c3                   	ret    

0080104d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	57                   	push   %edi
  801051:	56                   	push   %esi
  801052:	53                   	push   %ebx
  801053:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801056:	be 00 00 00 00       	mov    $0x0,%esi
  80105b:	b8 04 00 00 00       	mov    $0x4,%eax
  801060:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801063:	8b 55 08             	mov    0x8(%ebp),%edx
  801066:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801069:	89 f7                	mov    %esi,%edi
  80106b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 04                	push   $0x4
  801077:	68 df 2e 80 00       	push   $0x802edf
  80107c:	6a 23                	push   $0x23
  80107e:	68 fc 2e 80 00       	push   $0x802efc
  801083:	e8 64 f5 ff ff       	call   8005ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	b8 05 00 00 00       	mov    $0x5,%eax
  80109e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8010ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 05                	push   $0x5
  8010b9:	68 df 2e 80 00       	push   $0x802edf
  8010be:	6a 23                	push   $0x23
  8010c0:	68 fc 2e 80 00       	push   $0x802efc
  8010c5:	e8 22 f5 ff ff       	call   8005ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
  8010d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8010e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010eb:	89 df                	mov    %ebx,%edi
  8010ed:	89 de                	mov    %ebx,%esi
  8010ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	7e 17                	jle    80110c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	50                   	push   %eax
  8010f9:	6a 06                	push   $0x6
  8010fb:	68 df 2e 80 00       	push   $0x802edf
  801100:	6a 23                	push   $0x23
  801102:	68 fc 2e 80 00       	push   $0x802efc
  801107:	e8 e0 f4 ff ff       	call   8005ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80110c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801122:	b8 08 00 00 00       	mov    $0x8,%eax
  801127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112a:	8b 55 08             	mov    0x8(%ebp),%edx
  80112d:	89 df                	mov    %ebx,%edi
  80112f:	89 de                	mov    %ebx,%esi
  801131:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801133:	85 c0                	test   %eax,%eax
  801135:	7e 17                	jle    80114e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	50                   	push   %eax
  80113b:	6a 08                	push   $0x8
  80113d:	68 df 2e 80 00       	push   $0x802edf
  801142:	6a 23                	push   $0x23
  801144:	68 fc 2e 80 00       	push   $0x802efc
  801149:	e8 9e f4 ff ff       	call   8005ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	57                   	push   %edi
  80115a:	56                   	push   %esi
  80115b:	53                   	push   %ebx
  80115c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801164:	b8 09 00 00 00       	mov    $0x9,%eax
  801169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116c:	8b 55 08             	mov    0x8(%ebp),%edx
  80116f:	89 df                	mov    %ebx,%edi
  801171:	89 de                	mov    %ebx,%esi
  801173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801175:	85 c0                	test   %eax,%eax
  801177:	7e 17                	jle    801190 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	50                   	push   %eax
  80117d:	6a 09                	push   $0x9
  80117f:	68 df 2e 80 00       	push   $0x802edf
  801184:	6a 23                	push   $0x23
  801186:	68 fc 2e 80 00       	push   $0x802efc
  80118b:	e8 5c f4 ff ff       	call   8005ec <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	57                   	push   %edi
  80119c:	56                   	push   %esi
  80119d:	53                   	push   %ebx
  80119e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	89 df                	mov    %ebx,%edi
  8011b3:	89 de                	mov    %ebx,%esi
  8011b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	7e 17                	jle    8011d2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	50                   	push   %eax
  8011bf:	6a 0a                	push   $0xa
  8011c1:	68 df 2e 80 00       	push   $0x802edf
  8011c6:	6a 23                	push   $0x23
  8011c8:	68 fc 2e 80 00       	push   $0x802efc
  8011cd:	e8 1a f4 ff ff       	call   8005ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e0:	be 00 00 00 00       	mov    $0x0,%esi
  8011e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	57                   	push   %edi
  801201:	56                   	push   %esi
  801202:	53                   	push   %ebx
  801203:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801206:	b9 00 00 00 00       	mov    $0x0,%ecx
  80120b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801210:	8b 55 08             	mov    0x8(%ebp),%edx
  801213:	89 cb                	mov    %ecx,%ebx
  801215:	89 cf                	mov    %ecx,%edi
  801217:	89 ce                	mov    %ecx,%esi
  801219:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80121b:	85 c0                	test   %eax,%eax
  80121d:	7e 17                	jle    801236 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	50                   	push   %eax
  801223:	6a 0d                	push   $0xd
  801225:	68 df 2e 80 00       	push   $0x802edf
  80122a:	6a 23                	push   $0x23
  80122c:	68 fc 2e 80 00       	push   $0x802efc
  801231:	e8 b6 f3 ff ff       	call   8005ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801236:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801239:	5b                   	pop    %ebx
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801244:	ba 00 00 00 00       	mov    $0x0,%edx
  801249:	b8 0e 00 00 00       	mov    $0xe,%eax
  80124e:	89 d1                	mov    %edx,%ecx
  801250:	89 d3                	mov    %edx,%ebx
  801252:	89 d7                	mov    %edx,%edi
  801254:	89 d6                	mov    %edx,%esi
  801256:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801258:	5b                   	pop    %ebx
  801259:	5e                   	pop    %esi
  80125a:	5f                   	pop    %edi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801260:	8b 45 08             	mov    0x8(%ebp),%eax
  801263:	05 00 00 00 30       	add    $0x30000000,%eax
  801268:	c1 e8 0c             	shr    $0xc,%eax
}
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801270:	8b 45 08             	mov    0x8(%ebp),%eax
  801273:	05 00 00 00 30       	add    $0x30000000,%eax
  801278:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80127d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80128f:	89 c2                	mov    %eax,%edx
  801291:	c1 ea 16             	shr    $0x16,%edx
  801294:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129b:	f6 c2 01             	test   $0x1,%dl
  80129e:	74 11                	je     8012b1 <fd_alloc+0x2d>
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 0c             	shr    $0xc,%edx
  8012a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	75 09                	jne    8012ba <fd_alloc+0x36>
			*fd_store = fd;
  8012b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b8:	eb 17                	jmp    8012d1 <fd_alloc+0x4d>
  8012ba:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012bf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012c4:	75 c9                	jne    80128f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012cc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012d1:	5d                   	pop    %ebp
  8012d2:	c3                   	ret    

008012d3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d9:	83 f8 1f             	cmp    $0x1f,%eax
  8012dc:	77 36                	ja     801314 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012de:	c1 e0 0c             	shl    $0xc,%eax
  8012e1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	c1 ea 16             	shr    $0x16,%edx
  8012eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f2:	f6 c2 01             	test   $0x1,%dl
  8012f5:	74 24                	je     80131b <fd_lookup+0x48>
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	c1 ea 0c             	shr    $0xc,%edx
  8012fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801303:	f6 c2 01             	test   $0x1,%dl
  801306:	74 1a                	je     801322 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801308:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130b:	89 02                	mov    %eax,(%edx)
	return 0;
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
  801312:	eb 13                	jmp    801327 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801314:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801319:	eb 0c                	jmp    801327 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80131b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801320:	eb 05                	jmp    801327 <fd_lookup+0x54>
  801322:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    

00801329 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801332:	ba 88 2f 80 00       	mov    $0x802f88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801337:	eb 13                	jmp    80134c <dev_lookup+0x23>
  801339:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80133c:	39 08                	cmp    %ecx,(%eax)
  80133e:	75 0c                	jne    80134c <dev_lookup+0x23>
			*dev = devtab[i];
  801340:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801343:	89 01                	mov    %eax,(%ecx)
			return 0;
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
  80134a:	eb 2e                	jmp    80137a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80134c:	8b 02                	mov    (%edx),%eax
  80134e:	85 c0                	test   %eax,%eax
  801350:	75 e7                	jne    801339 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801352:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801357:	8b 40 48             	mov    0x48(%eax),%eax
  80135a:	83 ec 04             	sub    $0x4,%esp
  80135d:	51                   	push   %ecx
  80135e:	50                   	push   %eax
  80135f:	68 0c 2f 80 00       	push   $0x802f0c
  801364:	e8 5c f3 ff ff       	call   8006c5 <cprintf>
	*dev = 0;
  801369:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 10             	sub    $0x10,%esp
  801384:	8b 75 08             	mov    0x8(%ebp),%esi
  801387:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80138a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801394:	c1 e8 0c             	shr    $0xc,%eax
  801397:	50                   	push   %eax
  801398:	e8 36 ff ff ff       	call   8012d3 <fd_lookup>
  80139d:	83 c4 08             	add    $0x8,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 05                	js     8013a9 <fd_close+0x2d>
	    || fd != fd2)
  8013a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013a7:	74 0c                	je     8013b5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013a9:	84 db                	test   %bl,%bl
  8013ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b0:	0f 44 c2             	cmove  %edx,%eax
  8013b3:	eb 41                	jmp    8013f6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 36                	pushl  (%esi)
  8013be:	e8 66 ff ff ff       	call   801329 <dev_lookup>
  8013c3:	89 c3                	mov    %eax,%ebx
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 1a                	js     8013e6 <fd_close+0x6a>
		if (dev->dev_close)
  8013cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	74 0b                	je     8013e6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	56                   	push   %esi
  8013df:	ff d0                	call   *%eax
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	56                   	push   %esi
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 e1 fc ff ff       	call   8010d2 <sys_page_unmap>
	return r;
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 d8                	mov    %ebx,%eax
}
  8013f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801403:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801406:	50                   	push   %eax
  801407:	ff 75 08             	pushl  0x8(%ebp)
  80140a:	e8 c4 fe ff ff       	call   8012d3 <fd_lookup>
  80140f:	83 c4 08             	add    $0x8,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 10                	js     801426 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	6a 01                	push   $0x1
  80141b:	ff 75 f4             	pushl  -0xc(%ebp)
  80141e:	e8 59 ff ff ff       	call   80137c <fd_close>
  801423:	83 c4 10             	add    $0x10,%esp
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <close_all>:

void
close_all(void)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80142f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	53                   	push   %ebx
  801438:	e8 c0 ff ff ff       	call   8013fd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80143d:	83 c3 01             	add    $0x1,%ebx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	83 fb 20             	cmp    $0x20,%ebx
  801446:	75 ec                	jne    801434 <close_all+0xc>
		close(i);
}
  801448:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	57                   	push   %edi
  801451:	56                   	push   %esi
  801452:	53                   	push   %ebx
  801453:	83 ec 2c             	sub    $0x2c,%esp
  801456:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801459:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	ff 75 08             	pushl  0x8(%ebp)
  801460:	e8 6e fe ff ff       	call   8012d3 <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	0f 88 c1 00 00 00    	js     801531 <dup+0xe4>
		return r;
	close(newfdnum);
  801470:	83 ec 0c             	sub    $0xc,%esp
  801473:	56                   	push   %esi
  801474:	e8 84 ff ff ff       	call   8013fd <close>

	newfd = INDEX2FD(newfdnum);
  801479:	89 f3                	mov    %esi,%ebx
  80147b:	c1 e3 0c             	shl    $0xc,%ebx
  80147e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801484:	83 c4 04             	add    $0x4,%esp
  801487:	ff 75 e4             	pushl  -0x1c(%ebp)
  80148a:	e8 de fd ff ff       	call   80126d <fd2data>
  80148f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801491:	89 1c 24             	mov    %ebx,(%esp)
  801494:	e8 d4 fd ff ff       	call   80126d <fd2data>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80149f:	89 f8                	mov    %edi,%eax
  8014a1:	c1 e8 16             	shr    $0x16,%eax
  8014a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014ab:	a8 01                	test   $0x1,%al
  8014ad:	74 37                	je     8014e6 <dup+0x99>
  8014af:	89 f8                	mov    %edi,%eax
  8014b1:	c1 e8 0c             	shr    $0xc,%eax
  8014b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014bb:	f6 c2 01             	test   $0x1,%dl
  8014be:	74 26                	je     8014e6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cf:	50                   	push   %eax
  8014d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d3:	6a 00                	push   $0x0
  8014d5:	57                   	push   %edi
  8014d6:	6a 00                	push   $0x0
  8014d8:	e8 b3 fb ff ff       	call   801090 <sys_page_map>
  8014dd:	89 c7                	mov    %eax,%edi
  8014df:	83 c4 20             	add    $0x20,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 2e                	js     801514 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014e9:	89 d0                	mov    %edx,%eax
  8014eb:	c1 e8 0c             	shr    $0xc,%eax
  8014ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fd:	50                   	push   %eax
  8014fe:	53                   	push   %ebx
  8014ff:	6a 00                	push   $0x0
  801501:	52                   	push   %edx
  801502:	6a 00                	push   $0x0
  801504:	e8 87 fb ff ff       	call   801090 <sys_page_map>
  801509:	89 c7                	mov    %eax,%edi
  80150b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80150e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801510:	85 ff                	test   %edi,%edi
  801512:	79 1d                	jns    801531 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	53                   	push   %ebx
  801518:	6a 00                	push   $0x0
  80151a:	e8 b3 fb ff ff       	call   8010d2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	ff 75 d4             	pushl  -0x2c(%ebp)
  801525:	6a 00                	push   $0x0
  801527:	e8 a6 fb ff ff       	call   8010d2 <sys_page_unmap>
	return r;
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	89 f8                	mov    %edi,%eax
}
  801531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5f                   	pop    %edi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    

00801539 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	53                   	push   %ebx
  80153d:	83 ec 14             	sub    $0x14,%esp
  801540:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801543:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	53                   	push   %ebx
  801548:	e8 86 fd ff ff       	call   8012d3 <fd_lookup>
  80154d:	83 c4 08             	add    $0x8,%esp
  801550:	89 c2                	mov    %eax,%edx
  801552:	85 c0                	test   %eax,%eax
  801554:	78 6d                	js     8015c3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801560:	ff 30                	pushl  (%eax)
  801562:	e8 c2 fd ff ff       	call   801329 <dev_lookup>
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 4c                	js     8015ba <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80156e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801571:	8b 42 08             	mov    0x8(%edx),%eax
  801574:	83 e0 03             	and    $0x3,%eax
  801577:	83 f8 01             	cmp    $0x1,%eax
  80157a:	75 21                	jne    80159d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80157c:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801581:	8b 40 48             	mov    0x48(%eax),%eax
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	53                   	push   %ebx
  801588:	50                   	push   %eax
  801589:	68 4d 2f 80 00       	push   $0x802f4d
  80158e:	e8 32 f1 ff ff       	call   8006c5 <cprintf>
		return -E_INVAL;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159b:	eb 26                	jmp    8015c3 <read+0x8a>
	}
	if (!dev->dev_read)
  80159d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a0:	8b 40 08             	mov    0x8(%eax),%eax
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	74 17                	je     8015be <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	ff 75 10             	pushl  0x10(%ebp)
  8015ad:	ff 75 0c             	pushl  0xc(%ebp)
  8015b0:	52                   	push   %edx
  8015b1:	ff d0                	call   *%eax
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	eb 09                	jmp    8015c3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	eb 05                	jmp    8015c3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015c3:	89 d0                	mov    %edx,%eax
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	57                   	push   %edi
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015de:	eb 21                	jmp    801601 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	89 f0                	mov    %esi,%eax
  8015e5:	29 d8                	sub    %ebx,%eax
  8015e7:	50                   	push   %eax
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	03 45 0c             	add    0xc(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	57                   	push   %edi
  8015ef:	e8 45 ff ff ff       	call   801539 <read>
		if (m < 0)
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 10                	js     80160b <readn+0x41>
			return m;
		if (m == 0)
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	74 0a                	je     801609 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ff:	01 c3                	add    %eax,%ebx
  801601:	39 f3                	cmp    %esi,%ebx
  801603:	72 db                	jb     8015e0 <readn+0x16>
  801605:	89 d8                	mov    %ebx,%eax
  801607:	eb 02                	jmp    80160b <readn+0x41>
  801609:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80160b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5f                   	pop    %edi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	53                   	push   %ebx
  801617:	83 ec 14             	sub    $0x14,%esp
  80161a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	53                   	push   %ebx
  801622:	e8 ac fc ff ff       	call   8012d3 <fd_lookup>
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 68                	js     801698 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801636:	50                   	push   %eax
  801637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163a:	ff 30                	pushl  (%eax)
  80163c:	e8 e8 fc ff ff       	call   801329 <dev_lookup>
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	78 47                	js     80168f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80164f:	75 21                	jne    801672 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801651:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801656:	8b 40 48             	mov    0x48(%eax),%eax
  801659:	83 ec 04             	sub    $0x4,%esp
  80165c:	53                   	push   %ebx
  80165d:	50                   	push   %eax
  80165e:	68 69 2f 80 00       	push   $0x802f69
  801663:	e8 5d f0 ff ff       	call   8006c5 <cprintf>
		return -E_INVAL;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801670:	eb 26                	jmp    801698 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801672:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801675:	8b 52 0c             	mov    0xc(%edx),%edx
  801678:	85 d2                	test   %edx,%edx
  80167a:	74 17                	je     801693 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80167c:	83 ec 04             	sub    $0x4,%esp
  80167f:	ff 75 10             	pushl  0x10(%ebp)
  801682:	ff 75 0c             	pushl  0xc(%ebp)
  801685:	50                   	push   %eax
  801686:	ff d2                	call   *%edx
  801688:	89 c2                	mov    %eax,%edx
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	eb 09                	jmp    801698 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168f:	89 c2                	mov    %eax,%edx
  801691:	eb 05                	jmp    801698 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801693:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801698:	89 d0                	mov    %edx,%eax
  80169a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <seek>:

int
seek(int fdnum, off_t offset)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	ff 75 08             	pushl  0x8(%ebp)
  8016ac:	e8 22 fc ff ff       	call   8012d3 <fd_lookup>
  8016b1:	83 c4 08             	add    $0x8,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 0e                	js     8016c6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016be:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 14             	sub    $0x14,%esp
  8016cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	53                   	push   %ebx
  8016d7:	e8 f7 fb ff ff       	call   8012d3 <fd_lookup>
  8016dc:	83 c4 08             	add    $0x8,%esp
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 65                	js     80174a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	ff 30                	pushl  (%eax)
  8016f1:	e8 33 fc ff ff       	call   801329 <dev_lookup>
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 44                	js     801741 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801700:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801704:	75 21                	jne    801727 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801706:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80170b:	8b 40 48             	mov    0x48(%eax),%eax
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	53                   	push   %ebx
  801712:	50                   	push   %eax
  801713:	68 2c 2f 80 00       	push   $0x802f2c
  801718:	e8 a8 ef ff ff       	call   8006c5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801725:	eb 23                	jmp    80174a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801727:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172a:	8b 52 18             	mov    0x18(%edx),%edx
  80172d:	85 d2                	test   %edx,%edx
  80172f:	74 14                	je     801745 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	ff 75 0c             	pushl  0xc(%ebp)
  801737:	50                   	push   %eax
  801738:	ff d2                	call   *%edx
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	eb 09                	jmp    80174a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801741:	89 c2                	mov    %eax,%edx
  801743:	eb 05                	jmp    80174a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801745:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80174a:	89 d0                	mov    %edx,%eax
  80174c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	83 ec 14             	sub    $0x14,%esp
  801758:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	ff 75 08             	pushl  0x8(%ebp)
  801762:	e8 6c fb ff ff       	call   8012d3 <fd_lookup>
  801767:	83 c4 08             	add    $0x8,%esp
  80176a:	89 c2                	mov    %eax,%edx
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 58                	js     8017c8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801770:	83 ec 08             	sub    $0x8,%esp
  801773:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801776:	50                   	push   %eax
  801777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177a:	ff 30                	pushl  (%eax)
  80177c:	e8 a8 fb ff ff       	call   801329 <dev_lookup>
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	85 c0                	test   %eax,%eax
  801786:	78 37                	js     8017bf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80178f:	74 32                	je     8017c3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801791:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801794:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80179b:	00 00 00 
	stat->st_isdir = 0;
  80179e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a5:	00 00 00 
	stat->st_dev = dev;
  8017a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	53                   	push   %ebx
  8017b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b5:	ff 50 14             	call   *0x14(%eax)
  8017b8:	89 c2                	mov    %eax,%edx
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	eb 09                	jmp    8017c8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	eb 05                	jmp    8017c8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017c8:	89 d0                	mov    %edx,%eax
  8017ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	56                   	push   %esi
  8017d3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	6a 00                	push   $0x0
  8017d9:	ff 75 08             	pushl  0x8(%ebp)
  8017dc:	e8 d6 01 00 00       	call   8019b7 <open>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 1b                	js     801805 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	ff 75 0c             	pushl  0xc(%ebp)
  8017f0:	50                   	push   %eax
  8017f1:	e8 5b ff ff ff       	call   801751 <fstat>
  8017f6:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f8:	89 1c 24             	mov    %ebx,(%esp)
  8017fb:	e8 fd fb ff ff       	call   8013fd <close>
	return r;
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	89 f0                	mov    %esi,%eax
}
  801805:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	56                   	push   %esi
  801810:	53                   	push   %ebx
  801811:	89 c6                	mov    %eax,%esi
  801813:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801815:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  80181c:	75 12                	jne    801830 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80181e:	83 ec 0c             	sub    $0xc,%esp
  801821:	6a 01                	push   $0x1
  801823:	e8 c2 0e 00 00       	call   8026ea <ipc_find_env>
  801828:	a3 10 50 80 00       	mov    %eax,0x805010
  80182d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801830:	6a 07                	push   $0x7
  801832:	68 00 60 80 00       	push   $0x806000
  801837:	56                   	push   %esi
  801838:	ff 35 10 50 80 00    	pushl  0x805010
  80183e:	e8 53 0e 00 00       	call   802696 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801843:	83 c4 0c             	add    $0xc,%esp
  801846:	6a 00                	push   $0x0
  801848:	53                   	push   %ebx
  801849:	6a 00                	push   $0x0
  80184b:	e8 df 0d 00 00       	call   80262f <ipc_recv>
}
  801850:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185d:	8b 45 08             	mov    0x8(%ebp),%eax
  801860:	8b 40 0c             	mov    0xc(%eax),%eax
  801863:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186b:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801870:	ba 00 00 00 00       	mov    $0x0,%edx
  801875:	b8 02 00 00 00       	mov    $0x2,%eax
  80187a:	e8 8d ff ff ff       	call   80180c <fsipc>
}
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	8b 40 0c             	mov    0xc(%eax),%eax
  80188d:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	b8 06 00 00 00       	mov    $0x6,%eax
  80189c:	e8 6b ff ff ff       	call   80180c <fsipc>
}
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 04             	sub    $0x4,%esp
  8018aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b3:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c2:	e8 45 ff ff ff       	call   80180c <fsipc>
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 2c                	js     8018f7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	68 00 60 80 00       	push   $0x806000
  8018d3:	53                   	push   %ebx
  8018d4:	e8 71 f3 ff ff       	call   800c4a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018d9:	a1 80 60 80 00       	mov    0x806080,%eax
  8018de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e4:	a1 84 60 80 00       	mov    0x806084,%eax
  8018e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801905:	8b 55 08             	mov    0x8(%ebp),%edx
  801908:	8b 52 0c             	mov    0xc(%edx),%edx
  80190b:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801911:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801916:	50                   	push   %eax
  801917:	ff 75 0c             	pushl  0xc(%ebp)
  80191a:	68 08 60 80 00       	push   $0x806008
  80191f:	e8 b8 f4 ff ff       	call   800ddc <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801924:	ba 00 00 00 00       	mov    $0x0,%edx
  801929:	b8 04 00 00 00       	mov    $0x4,%eax
  80192e:	e8 d9 fe ff ff       	call   80180c <fsipc>

}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	8b 40 0c             	mov    0xc(%eax),%eax
  801943:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801948:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80194e:	ba 00 00 00 00       	mov    $0x0,%edx
  801953:	b8 03 00 00 00       	mov    $0x3,%eax
  801958:	e8 af fe ff ff       	call   80180c <fsipc>
  80195d:	89 c3                	mov    %eax,%ebx
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 4b                	js     8019ae <devfile_read+0x79>
		return r;
	assert(r <= n);
  801963:	39 c6                	cmp    %eax,%esi
  801965:	73 16                	jae    80197d <devfile_read+0x48>
  801967:	68 9c 2f 80 00       	push   $0x802f9c
  80196c:	68 a3 2f 80 00       	push   $0x802fa3
  801971:	6a 7c                	push   $0x7c
  801973:	68 b8 2f 80 00       	push   $0x802fb8
  801978:	e8 6f ec ff ff       	call   8005ec <_panic>
	assert(r <= PGSIZE);
  80197d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801982:	7e 16                	jle    80199a <devfile_read+0x65>
  801984:	68 c3 2f 80 00       	push   $0x802fc3
  801989:	68 a3 2f 80 00       	push   $0x802fa3
  80198e:	6a 7d                	push   $0x7d
  801990:	68 b8 2f 80 00       	push   $0x802fb8
  801995:	e8 52 ec ff ff       	call   8005ec <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80199a:	83 ec 04             	sub    $0x4,%esp
  80199d:	50                   	push   %eax
  80199e:	68 00 60 80 00       	push   $0x806000
  8019a3:	ff 75 0c             	pushl  0xc(%ebp)
  8019a6:	e8 31 f4 ff ff       	call   800ddc <memmove>
	return r;
  8019ab:	83 c4 10             	add    $0x10,%esp
}
  8019ae:	89 d8                	mov    %ebx,%eax
  8019b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b3:	5b                   	pop    %ebx
  8019b4:	5e                   	pop    %esi
  8019b5:	5d                   	pop    %ebp
  8019b6:	c3                   	ret    

008019b7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 20             	sub    $0x20,%esp
  8019be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019c1:	53                   	push   %ebx
  8019c2:	e8 4a f2 ff ff       	call   800c11 <strlen>
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019cf:	7f 67                	jg     801a38 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d1:	83 ec 0c             	sub    $0xc,%esp
  8019d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d7:	50                   	push   %eax
  8019d8:	e8 a7 f8 ff ff       	call   801284 <fd_alloc>
  8019dd:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 57                	js     801a3d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	53                   	push   %ebx
  8019ea:	68 00 60 80 00       	push   $0x806000
  8019ef:	e8 56 f2 ff ff       	call   800c4a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f7:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801a04:	e8 03 fe ff ff       	call   80180c <fsipc>
  801a09:	89 c3                	mov    %eax,%ebx
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	79 14                	jns    801a26 <open+0x6f>
		fd_close(fd, 0);
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	6a 00                	push   $0x0
  801a17:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1a:	e8 5d f9 ff ff       	call   80137c <fd_close>
		return r;
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	89 da                	mov    %ebx,%edx
  801a24:	eb 17                	jmp    801a3d <open+0x86>
	}

	return fd2num(fd);
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2c:	e8 2c f8 ff ff       	call   80125d <fd2num>
  801a31:	89 c2                	mov    %eax,%edx
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	eb 05                	jmp    801a3d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a38:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a3d:	89 d0                	mov    %edx,%eax
  801a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a54:	e8 b3 fd ff ff       	call   80180c <fsipc>
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	ff 75 08             	pushl  0x8(%ebp)
  801a69:	e8 ff f7 ff ff       	call   80126d <fd2data>
  801a6e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a70:	83 c4 08             	add    $0x8,%esp
  801a73:	68 cf 2f 80 00       	push   $0x802fcf
  801a78:	53                   	push   %ebx
  801a79:	e8 cc f1 ff ff       	call   800c4a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a7e:	8b 46 04             	mov    0x4(%esi),%eax
  801a81:	2b 06                	sub    (%esi),%eax
  801a83:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a89:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a90:	00 00 00 
	stat->st_dev = &devpipe;
  801a93:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  801a9a:	40 80 00 
	return 0;
}
  801a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	53                   	push   %ebx
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ab3:	53                   	push   %ebx
  801ab4:	6a 00                	push   $0x0
  801ab6:	e8 17 f6 ff ff       	call   8010d2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801abb:	89 1c 24             	mov    %ebx,(%esp)
  801abe:	e8 aa f7 ff ff       	call   80126d <fd2data>
  801ac3:	83 c4 08             	add    $0x8,%esp
  801ac6:	50                   	push   %eax
  801ac7:	6a 00                	push   $0x0
  801ac9:	e8 04 f6 ff ff       	call   8010d2 <sys_page_unmap>
}
  801ace:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	57                   	push   %edi
  801ad7:	56                   	push   %esi
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 1c             	sub    $0x1c,%esp
  801adc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801adf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ae1:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801ae6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	ff 75 e0             	pushl  -0x20(%ebp)
  801aef:	e8 2f 0c 00 00       	call   802723 <pageref>
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	89 3c 24             	mov    %edi,(%esp)
  801af9:	e8 25 0c 00 00       	call   802723 <pageref>
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	39 c3                	cmp    %eax,%ebx
  801b03:	0f 94 c1             	sete   %cl
  801b06:	0f b6 c9             	movzbl %cl,%ecx
  801b09:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b0c:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  801b12:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b15:	39 ce                	cmp    %ecx,%esi
  801b17:	74 1b                	je     801b34 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b19:	39 c3                	cmp    %eax,%ebx
  801b1b:	75 c4                	jne    801ae1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b1d:	8b 42 58             	mov    0x58(%edx),%eax
  801b20:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b23:	50                   	push   %eax
  801b24:	56                   	push   %esi
  801b25:	68 d6 2f 80 00       	push   $0x802fd6
  801b2a:	e8 96 eb ff ff       	call   8006c5 <cprintf>
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	eb ad                	jmp    801ae1 <_pipeisclosed+0xe>
	}
}
  801b34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5f                   	pop    %edi
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	57                   	push   %edi
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	83 ec 28             	sub    $0x28,%esp
  801b48:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b4b:	56                   	push   %esi
  801b4c:	e8 1c f7 ff ff       	call   80126d <fd2data>
  801b51:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	bf 00 00 00 00       	mov    $0x0,%edi
  801b5b:	eb 4b                	jmp    801ba8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b5d:	89 da                	mov    %ebx,%edx
  801b5f:	89 f0                	mov    %esi,%eax
  801b61:	e8 6d ff ff ff       	call   801ad3 <_pipeisclosed>
  801b66:	85 c0                	test   %eax,%eax
  801b68:	75 48                	jne    801bb2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b6a:	e8 bf f4 ff ff       	call   80102e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b6f:	8b 43 04             	mov    0x4(%ebx),%eax
  801b72:	8b 0b                	mov    (%ebx),%ecx
  801b74:	8d 51 20             	lea    0x20(%ecx),%edx
  801b77:	39 d0                	cmp    %edx,%eax
  801b79:	73 e2                	jae    801b5d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b82:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b85:	89 c2                	mov    %eax,%edx
  801b87:	c1 fa 1f             	sar    $0x1f,%edx
  801b8a:	89 d1                	mov    %edx,%ecx
  801b8c:	c1 e9 1b             	shr    $0x1b,%ecx
  801b8f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b92:	83 e2 1f             	and    $0x1f,%edx
  801b95:	29 ca                	sub    %ecx,%edx
  801b97:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b9b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b9f:	83 c0 01             	add    $0x1,%eax
  801ba2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba5:	83 c7 01             	add    $0x1,%edi
  801ba8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bab:	75 c2                	jne    801b6f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bad:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb0:	eb 05                	jmp    801bb7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	57                   	push   %edi
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 18             	sub    $0x18,%esp
  801bc8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bcb:	57                   	push   %edi
  801bcc:	e8 9c f6 ff ff       	call   80126d <fd2data>
  801bd1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bdb:	eb 3d                	jmp    801c1a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bdd:	85 db                	test   %ebx,%ebx
  801bdf:	74 04                	je     801be5 <devpipe_read+0x26>
				return i;
  801be1:	89 d8                	mov    %ebx,%eax
  801be3:	eb 44                	jmp    801c29 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801be5:	89 f2                	mov    %esi,%edx
  801be7:	89 f8                	mov    %edi,%eax
  801be9:	e8 e5 fe ff ff       	call   801ad3 <_pipeisclosed>
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	75 32                	jne    801c24 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bf2:	e8 37 f4 ff ff       	call   80102e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bf7:	8b 06                	mov    (%esi),%eax
  801bf9:	3b 46 04             	cmp    0x4(%esi),%eax
  801bfc:	74 df                	je     801bdd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bfe:	99                   	cltd   
  801bff:	c1 ea 1b             	shr    $0x1b,%edx
  801c02:	01 d0                	add    %edx,%eax
  801c04:	83 e0 1f             	and    $0x1f,%eax
  801c07:	29 d0                	sub    %edx,%eax
  801c09:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c11:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c14:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c17:	83 c3 01             	add    $0x1,%ebx
  801c1a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c1d:	75 d8                	jne    801bf7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c22:	eb 05                	jmp    801c29 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c24:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	56                   	push   %esi
  801c35:	53                   	push   %ebx
  801c36:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3c:	50                   	push   %eax
  801c3d:	e8 42 f6 ff ff       	call   801284 <fd_alloc>
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	89 c2                	mov    %eax,%edx
  801c47:	85 c0                	test   %eax,%eax
  801c49:	0f 88 2c 01 00 00    	js     801d7b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4f:	83 ec 04             	sub    $0x4,%esp
  801c52:	68 07 04 00 00       	push   $0x407
  801c57:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5a:	6a 00                	push   $0x0
  801c5c:	e8 ec f3 ff ff       	call   80104d <sys_page_alloc>
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	89 c2                	mov    %eax,%edx
  801c66:	85 c0                	test   %eax,%eax
  801c68:	0f 88 0d 01 00 00    	js     801d7b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c6e:	83 ec 0c             	sub    $0xc,%esp
  801c71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c74:	50                   	push   %eax
  801c75:	e8 0a f6 ff ff       	call   801284 <fd_alloc>
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	0f 88 e2 00 00 00    	js     801d69 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c87:	83 ec 04             	sub    $0x4,%esp
  801c8a:	68 07 04 00 00       	push   $0x407
  801c8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c92:	6a 00                	push   $0x0
  801c94:	e8 b4 f3 ff ff       	call   80104d <sys_page_alloc>
  801c99:	89 c3                	mov    %eax,%ebx
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	0f 88 c3 00 00 00    	js     801d69 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ca6:	83 ec 0c             	sub    $0xc,%esp
  801ca9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cac:	e8 bc f5 ff ff       	call   80126d <fd2data>
  801cb1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb3:	83 c4 0c             	add    $0xc,%esp
  801cb6:	68 07 04 00 00       	push   $0x407
  801cbb:	50                   	push   %eax
  801cbc:	6a 00                	push   $0x0
  801cbe:	e8 8a f3 ff ff       	call   80104d <sys_page_alloc>
  801cc3:	89 c3                	mov    %eax,%ebx
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	0f 88 89 00 00 00    	js     801d59 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd6:	e8 92 f5 ff ff       	call   80126d <fd2data>
  801cdb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ce2:	50                   	push   %eax
  801ce3:	6a 00                	push   $0x0
  801ce5:	56                   	push   %esi
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 a3 f3 ff ff       	call   801090 <sys_page_map>
  801ced:	89 c3                	mov    %eax,%ebx
  801cef:	83 c4 20             	add    $0x20,%esp
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 55                	js     801d4b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cf6:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cff:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d04:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d0b:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801d11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d14:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d19:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d20:	83 ec 0c             	sub    $0xc,%esp
  801d23:	ff 75 f4             	pushl  -0xc(%ebp)
  801d26:	e8 32 f5 ff ff       	call   80125d <fd2num>
  801d2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d2e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d30:	83 c4 04             	add    $0x4,%esp
  801d33:	ff 75 f0             	pushl  -0x10(%ebp)
  801d36:	e8 22 f5 ff ff       	call   80125d <fd2num>
  801d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	ba 00 00 00 00       	mov    $0x0,%edx
  801d49:	eb 30                	jmp    801d7b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d4b:	83 ec 08             	sub    $0x8,%esp
  801d4e:	56                   	push   %esi
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 7c f3 ff ff       	call   8010d2 <sys_page_unmap>
  801d56:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d59:	83 ec 08             	sub    $0x8,%esp
  801d5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 6c f3 ff ff       	call   8010d2 <sys_page_unmap>
  801d66:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d69:	83 ec 08             	sub    $0x8,%esp
  801d6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6f:	6a 00                	push   $0x0
  801d71:	e8 5c f3 ff ff       	call   8010d2 <sys_page_unmap>
  801d76:	83 c4 10             	add    $0x10,%esp
  801d79:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    

00801d84 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8d:	50                   	push   %eax
  801d8e:	ff 75 08             	pushl  0x8(%ebp)
  801d91:	e8 3d f5 ff ff       	call   8012d3 <fd_lookup>
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	78 18                	js     801db5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d9d:	83 ec 0c             	sub    $0xc,%esp
  801da0:	ff 75 f4             	pushl  -0xc(%ebp)
  801da3:	e8 c5 f4 ff ff       	call   80126d <fd2data>
	return _pipeisclosed(fd, p);
  801da8:	89 c2                	mov    %eax,%edx
  801daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dad:	e8 21 fd ff ff       	call   801ad3 <_pipeisclosed>
  801db2:	83 c4 10             	add    $0x10,%esp
}
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801dbd:	68 ee 2f 80 00       	push   $0x802fee
  801dc2:	ff 75 0c             	pushl  0xc(%ebp)
  801dc5:	e8 80 ee ff ff       	call   800c4a <strcpy>
	return 0;
}
  801dca:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    

00801dd1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	53                   	push   %ebx
  801dd5:	83 ec 10             	sub    $0x10,%esp
  801dd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ddb:	53                   	push   %ebx
  801ddc:	e8 42 09 00 00       	call   802723 <pageref>
  801de1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801de4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801de9:	83 f8 01             	cmp    $0x1,%eax
  801dec:	75 10                	jne    801dfe <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801dee:	83 ec 0c             	sub    $0xc,%esp
  801df1:	ff 73 0c             	pushl  0xc(%ebx)
  801df4:	e8 c0 02 00 00       	call   8020b9 <nsipc_close>
  801df9:	89 c2                	mov    %eax,%edx
  801dfb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801dfe:	89 d0                	mov    %edx,%eax
  801e00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    

00801e05 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e0b:	6a 00                	push   $0x0
  801e0d:	ff 75 10             	pushl  0x10(%ebp)
  801e10:	ff 75 0c             	pushl  0xc(%ebp)
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	ff 70 0c             	pushl  0xc(%eax)
  801e19:	e8 78 03 00 00       	call   802196 <nsipc_send>
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e26:	6a 00                	push   $0x0
  801e28:	ff 75 10             	pushl  0x10(%ebp)
  801e2b:	ff 75 0c             	pushl  0xc(%ebp)
  801e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e31:	ff 70 0c             	pushl  0xc(%eax)
  801e34:	e8 f1 02 00 00       	call   80212a <nsipc_recv>
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e41:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e44:	52                   	push   %edx
  801e45:	50                   	push   %eax
  801e46:	e8 88 f4 ff ff       	call   8012d3 <fd_lookup>
  801e4b:	83 c4 10             	add    $0x10,%esp
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 17                	js     801e69 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e55:	8b 0d 5c 40 80 00    	mov    0x80405c,%ecx
  801e5b:	39 08                	cmp    %ecx,(%eax)
  801e5d:	75 05                	jne    801e64 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801e62:	eb 05                	jmp    801e69 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e64:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	56                   	push   %esi
  801e6f:	53                   	push   %ebx
  801e70:	83 ec 1c             	sub    $0x1c,%esp
  801e73:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	e8 06 f4 ff ff       	call   801284 <fd_alloc>
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 1b                	js     801ea2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	68 07 04 00 00       	push   $0x407
  801e8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e92:	6a 00                	push   $0x0
  801e94:	e8 b4 f1 ff ff       	call   80104d <sys_page_alloc>
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	79 10                	jns    801eb2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ea2:	83 ec 0c             	sub    $0xc,%esp
  801ea5:	56                   	push   %esi
  801ea6:	e8 0e 02 00 00       	call   8020b9 <nsipc_close>
		return r;
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	89 d8                	mov    %ebx,%eax
  801eb0:	eb 24                	jmp    801ed6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801eb2:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  801eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ec7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	50                   	push   %eax
  801ece:	e8 8a f3 ff ff       	call   80125d <fd2num>
  801ed3:	83 c4 10             	add    $0x10,%esp
}
  801ed6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed9:	5b                   	pop    %ebx
  801eda:	5e                   	pop    %esi
  801edb:	5d                   	pop    %ebp
  801edc:	c3                   	ret    

00801edd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801edd:	55                   	push   %ebp
  801ede:	89 e5                	mov    %esp,%ebp
  801ee0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee6:	e8 50 ff ff ff       	call   801e3b <fd2sockid>
		return r;
  801eeb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 1f                	js     801f10 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	ff 75 10             	pushl  0x10(%ebp)
  801ef7:	ff 75 0c             	pushl  0xc(%ebp)
  801efa:	50                   	push   %eax
  801efb:	e8 12 01 00 00       	call   802012 <nsipc_accept>
  801f00:	83 c4 10             	add    $0x10,%esp
		return r;
  801f03:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f05:	85 c0                	test   %eax,%eax
  801f07:	78 07                	js     801f10 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801f09:	e8 5d ff ff ff       	call   801e6b <alloc_sockfd>
  801f0e:	89 c1                	mov    %eax,%ecx
}
  801f10:	89 c8                	mov    %ecx,%eax
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    

00801f14 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1d:	e8 19 ff ff ff       	call   801e3b <fd2sockid>
  801f22:	85 c0                	test   %eax,%eax
  801f24:	78 12                	js     801f38 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801f26:	83 ec 04             	sub    $0x4,%esp
  801f29:	ff 75 10             	pushl  0x10(%ebp)
  801f2c:	ff 75 0c             	pushl  0xc(%ebp)
  801f2f:	50                   	push   %eax
  801f30:	e8 2d 01 00 00       	call   802062 <nsipc_bind>
  801f35:	83 c4 10             	add    $0x10,%esp
}
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <shutdown>:

int
shutdown(int s, int how)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f40:	8b 45 08             	mov    0x8(%ebp),%eax
  801f43:	e8 f3 fe ff ff       	call   801e3b <fd2sockid>
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	78 0f                	js     801f5b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f4c:	83 ec 08             	sub    $0x8,%esp
  801f4f:	ff 75 0c             	pushl  0xc(%ebp)
  801f52:	50                   	push   %eax
  801f53:	e8 3f 01 00 00       	call   802097 <nsipc_shutdown>
  801f58:	83 c4 10             	add    $0x10,%esp
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f63:	8b 45 08             	mov    0x8(%ebp),%eax
  801f66:	e8 d0 fe ff ff       	call   801e3b <fd2sockid>
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	78 12                	js     801f81 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f6f:	83 ec 04             	sub    $0x4,%esp
  801f72:	ff 75 10             	pushl  0x10(%ebp)
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	50                   	push   %eax
  801f79:	e8 55 01 00 00       	call   8020d3 <nsipc_connect>
  801f7e:	83 c4 10             	add    $0x10,%esp
}
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    

00801f83 <listen>:

int
listen(int s, int backlog)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f89:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8c:	e8 aa fe ff ff       	call   801e3b <fd2sockid>
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 0f                	js     801fa4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f95:	83 ec 08             	sub    $0x8,%esp
  801f98:	ff 75 0c             	pushl  0xc(%ebp)
  801f9b:	50                   	push   %eax
  801f9c:	e8 67 01 00 00       	call   802108 <nsipc_listen>
  801fa1:	83 c4 10             	add    $0x10,%esp
}
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    

00801fa6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fac:	ff 75 10             	pushl  0x10(%ebp)
  801faf:	ff 75 0c             	pushl  0xc(%ebp)
  801fb2:	ff 75 08             	pushl  0x8(%ebp)
  801fb5:	e8 3a 02 00 00       	call   8021f4 <nsipc_socket>
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 05                	js     801fc6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801fc1:	e8 a5 fe ff ff       	call   801e6b <alloc_sockfd>
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	53                   	push   %ebx
  801fcc:	83 ec 04             	sub    $0x4,%esp
  801fcf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fd1:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  801fd8:	75 12                	jne    801fec <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fda:	83 ec 0c             	sub    $0xc,%esp
  801fdd:	6a 02                	push   $0x2
  801fdf:	e8 06 07 00 00       	call   8026ea <ipc_find_env>
  801fe4:	a3 14 50 80 00       	mov    %eax,0x805014
  801fe9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fec:	6a 07                	push   $0x7
  801fee:	68 00 70 80 00       	push   $0x807000
  801ff3:	53                   	push   %ebx
  801ff4:	ff 35 14 50 80 00    	pushl  0x805014
  801ffa:	e8 97 06 00 00       	call   802696 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fff:	83 c4 0c             	add    $0xc,%esp
  802002:	6a 00                	push   $0x0
  802004:	6a 00                	push   $0x0
  802006:	6a 00                	push   $0x0
  802008:	e8 22 06 00 00       	call   80262f <ipc_recv>
}
  80200d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	56                   	push   %esi
  802016:	53                   	push   %ebx
  802017:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80201a:	8b 45 08             	mov    0x8(%ebp),%eax
  80201d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802022:	8b 06                	mov    (%esi),%eax
  802024:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802029:	b8 01 00 00 00       	mov    $0x1,%eax
  80202e:	e8 95 ff ff ff       	call   801fc8 <nsipc>
  802033:	89 c3                	mov    %eax,%ebx
  802035:	85 c0                	test   %eax,%eax
  802037:	78 20                	js     802059 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802039:	83 ec 04             	sub    $0x4,%esp
  80203c:	ff 35 10 70 80 00    	pushl  0x807010
  802042:	68 00 70 80 00       	push   $0x807000
  802047:	ff 75 0c             	pushl  0xc(%ebp)
  80204a:	e8 8d ed ff ff       	call   800ddc <memmove>
		*addrlen = ret->ret_addrlen;
  80204f:	a1 10 70 80 00       	mov    0x807010,%eax
  802054:	89 06                	mov    %eax,(%esi)
  802056:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802059:	89 d8                	mov    %ebx,%eax
  80205b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80205e:	5b                   	pop    %ebx
  80205f:	5e                   	pop    %esi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    

00802062 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	53                   	push   %ebx
  802066:	83 ec 08             	sub    $0x8,%esp
  802069:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80206c:	8b 45 08             	mov    0x8(%ebp),%eax
  80206f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802074:	53                   	push   %ebx
  802075:	ff 75 0c             	pushl  0xc(%ebp)
  802078:	68 04 70 80 00       	push   $0x807004
  80207d:	e8 5a ed ff ff       	call   800ddc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802082:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802088:	b8 02 00 00 00       	mov    $0x2,%eax
  80208d:	e8 36 ff ff ff       	call   801fc8 <nsipc>
}
  802092:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802095:	c9                   	leave  
  802096:	c3                   	ret    

00802097 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80209d:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8020a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8020ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8020b2:	e8 11 ff ff ff       	call   801fc8 <nsipc>
}
  8020b7:	c9                   	leave  
  8020b8:	c3                   	ret    

008020b9 <nsipc_close>:

int
nsipc_close(int s)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8020cc:	e8 f7 fe ff ff       	call   801fc8 <nsipc>
}
  8020d1:	c9                   	leave  
  8020d2:	c3                   	ret    

008020d3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	53                   	push   %ebx
  8020d7:	83 ec 08             	sub    $0x8,%esp
  8020da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020e5:	53                   	push   %ebx
  8020e6:	ff 75 0c             	pushl  0xc(%ebp)
  8020e9:	68 04 70 80 00       	push   $0x807004
  8020ee:	e8 e9 ec ff ff       	call   800ddc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020f3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8020fe:	e8 c5 fe ff ff       	call   801fc8 <nsipc>
}
  802103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
  802111:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802116:	8b 45 0c             	mov    0xc(%ebp),%eax
  802119:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80211e:	b8 06 00 00 00       	mov    $0x6,%eax
  802123:	e8 a0 fe ff ff       	call   801fc8 <nsipc>
}
  802128:	c9                   	leave  
  802129:	c3                   	ret    

0080212a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	56                   	push   %esi
  80212e:	53                   	push   %ebx
  80212f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802132:	8b 45 08             	mov    0x8(%ebp),%eax
  802135:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80213a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802140:	8b 45 14             	mov    0x14(%ebp),%eax
  802143:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802148:	b8 07 00 00 00       	mov    $0x7,%eax
  80214d:	e8 76 fe ff ff       	call   801fc8 <nsipc>
  802152:	89 c3                	mov    %eax,%ebx
  802154:	85 c0                	test   %eax,%eax
  802156:	78 35                	js     80218d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802158:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80215d:	7f 04                	jg     802163 <nsipc_recv+0x39>
  80215f:	39 c6                	cmp    %eax,%esi
  802161:	7d 16                	jge    802179 <nsipc_recv+0x4f>
  802163:	68 fa 2f 80 00       	push   $0x802ffa
  802168:	68 a3 2f 80 00       	push   $0x802fa3
  80216d:	6a 62                	push   $0x62
  80216f:	68 0f 30 80 00       	push   $0x80300f
  802174:	e8 73 e4 ff ff       	call   8005ec <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802179:	83 ec 04             	sub    $0x4,%esp
  80217c:	50                   	push   %eax
  80217d:	68 00 70 80 00       	push   $0x807000
  802182:	ff 75 0c             	pushl  0xc(%ebp)
  802185:	e8 52 ec ff ff       	call   800ddc <memmove>
  80218a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80218d:	89 d8                	mov    %ebx,%eax
  80218f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802192:	5b                   	pop    %ebx
  802193:	5e                   	pop    %esi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    

00802196 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802196:	55                   	push   %ebp
  802197:	89 e5                	mov    %esp,%ebp
  802199:	53                   	push   %ebx
  80219a:	83 ec 04             	sub    $0x4,%esp
  80219d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a3:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021a8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021ae:	7e 16                	jle    8021c6 <nsipc_send+0x30>
  8021b0:	68 1b 30 80 00       	push   $0x80301b
  8021b5:	68 a3 2f 80 00       	push   $0x802fa3
  8021ba:	6a 6d                	push   $0x6d
  8021bc:	68 0f 30 80 00       	push   $0x80300f
  8021c1:	e8 26 e4 ff ff       	call   8005ec <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021c6:	83 ec 04             	sub    $0x4,%esp
  8021c9:	53                   	push   %ebx
  8021ca:	ff 75 0c             	pushl  0xc(%ebp)
  8021cd:	68 0c 70 80 00       	push   $0x80700c
  8021d2:	e8 05 ec ff ff       	call   800ddc <memmove>
	nsipcbuf.send.req_size = size;
  8021d7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8021dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021e5:	b8 08 00 00 00       	mov    $0x8,%eax
  8021ea:	e8 d9 fd ff ff       	call   801fc8 <nsipc>
}
  8021ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021f2:	c9                   	leave  
  8021f3:	c3                   	ret    

008021f4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802202:	8b 45 0c             	mov    0xc(%ebp),%eax
  802205:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80220a:	8b 45 10             	mov    0x10(%ebp),%eax
  80220d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802212:	b8 09 00 00 00       	mov    $0x9,%eax
  802217:	e8 ac fd ff ff       	call   801fc8 <nsipc>
}
  80221c:	c9                   	leave  
  80221d:	c3                   	ret    

0080221e <free>:
	return v;
}

void
free(void *v)
{
  80221e:	55                   	push   %ebp
  80221f:	89 e5                	mov    %esp,%ebp
  802221:	53                   	push   %ebx
  802222:	83 ec 04             	sub    $0x4,%esp
  802225:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  802228:	85 db                	test   %ebx,%ebx
  80222a:	0f 84 97 00 00 00    	je     8022c7 <free+0xa9>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  802230:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  802236:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  80223b:	76 16                	jbe    802253 <free+0x35>
  80223d:	68 28 30 80 00       	push   $0x803028
  802242:	68 a3 2f 80 00       	push   $0x802fa3
  802247:	6a 7a                	push   $0x7a
  802249:	68 58 30 80 00       	push   $0x803058
  80224e:	e8 99 e3 ff ff       	call   8005ec <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  802253:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  802259:	eb 3a                	jmp    802295 <free+0x77>
		sys_page_unmap(0, c);
  80225b:	83 ec 08             	sub    $0x8,%esp
  80225e:	53                   	push   %ebx
  80225f:	6a 00                	push   $0x0
  802261:	e8 6c ee ff ff       	call   8010d2 <sys_page_unmap>
		c += PGSIZE;
  802266:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  80226c:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  802272:	83 c4 10             	add    $0x10,%esp
  802275:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  80227a:	76 19                	jbe    802295 <free+0x77>
  80227c:	68 65 30 80 00       	push   $0x803065
  802281:	68 a3 2f 80 00       	push   $0x802fa3
  802286:	68 81 00 00 00       	push   $0x81
  80228b:	68 58 30 80 00       	push   $0x803058
  802290:	e8 57 e3 ff ff       	call   8005ec <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  802295:	89 d8                	mov    %ebx,%eax
  802297:	c1 e8 0c             	shr    $0xc,%eax
  80229a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8022a1:	f6 c4 02             	test   $0x2,%ah
  8022a4:	75 b5                	jne    80225b <free+0x3d>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  8022a6:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  8022ac:	83 e8 01             	sub    $0x1,%eax
  8022af:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  8022b5:	85 c0                	test   %eax,%eax
  8022b7:	75 0e                	jne    8022c7 <free+0xa9>
		sys_page_unmap(0, c);
  8022b9:	83 ec 08             	sub    $0x8,%esp
  8022bc:	53                   	push   %ebx
  8022bd:	6a 00                	push   $0x0
  8022bf:	e8 0e ee ff ff       	call   8010d2 <sys_page_unmap>
  8022c4:	83 c4 10             	add    $0x10,%esp
}
  8022c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022ca:	c9                   	leave  
  8022cb:	c3                   	ret    

008022cc <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	57                   	push   %edi
  8022d0:	56                   	push   %esi
  8022d1:	53                   	push   %ebx
  8022d2:	83 ec 1c             	sub    $0x1c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  8022d5:	a1 18 50 80 00       	mov    0x805018,%eax
  8022da:	85 c0                	test   %eax,%eax
  8022dc:	75 22                	jne    802300 <malloc+0x34>
		mptr = mbegin;
  8022de:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8022e5:	00 00 08 

	n = ROUNDUP(n, 4);
  8022e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022eb:	83 c0 03             	add    $0x3,%eax
  8022ee:	83 e0 fc             	and    $0xfffffffc,%eax
  8022f1:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if (n >= MAXMALLOC)
  8022f4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  8022f9:	76 74                	jbe    80236f <malloc+0xa3>
  8022fb:	e9 7a 01 00 00       	jmp    80247a <malloc+0x1ae>
	void *v;

	if (mptr == 0)
		mptr = mbegin;

	n = ROUNDUP(n, 4);
  802300:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802303:	8d 53 03             	lea    0x3(%ebx),%edx
  802306:	83 e2 fc             	and    $0xfffffffc,%edx
  802309:	89 55 dc             	mov    %edx,-0x24(%ebp)

	if (n >= MAXMALLOC)
  80230c:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  802312:	0f 87 69 01 00 00    	ja     802481 <malloc+0x1b5>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  802318:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80231d:	74 50                	je     80236f <malloc+0xa3>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  80231f:	89 c1                	mov    %eax,%ecx
  802321:	c1 e9 0c             	shr    $0xc,%ecx
  802324:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  802328:	c1 ea 0c             	shr    $0xc,%edx
  80232b:	39 d1                	cmp    %edx,%ecx
  80232d:	75 20                	jne    80234f <malloc+0x83>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  80232f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  802335:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  80233b:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  80233f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802342:	01 c2                	add    %eax,%edx
  802344:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  80234a:	e9 55 01 00 00       	jmp    8024a4 <malloc+0x1d8>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  80234f:	83 ec 0c             	sub    $0xc,%esp
  802352:	50                   	push   %eax
  802353:	e8 c6 fe ff ff       	call   80221e <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  802358:	a1 18 50 80 00       	mov    0x805018,%eax
  80235d:	05 00 10 00 00       	add    $0x1000,%eax
  802362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802367:	a3 18 50 80 00       	mov    %eax,0x805018
  80236c:	83 c4 10             	add    $0x10,%esp
  80236f:	8b 35 18 50 80 00    	mov    0x805018,%esi
	return 1;
}

void*
malloc(size_t n)
{
  802375:	c7 45 d8 02 00 00 00 	movl   $0x2,-0x28(%ebp)
  80237c:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802380:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802383:	8d 78 04             	lea    0x4(%eax),%edi
  802386:	89 75 e0             	mov    %esi,-0x20(%ebp)
  802389:	89 fb                	mov    %edi,%ebx
  80238b:	8d 0c 37             	lea    (%edi,%esi,1),%ecx
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80238e:	89 f0                	mov    %esi,%eax
  802390:	eb 36                	jmp    8023c8 <malloc+0xfc>
		if (va >= (uintptr_t) mend
  802392:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  802397:	0f 87 eb 00 00 00    	ja     802488 <malloc+0x1bc>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  80239d:	89 c2                	mov    %eax,%edx
  80239f:	c1 ea 16             	shr    $0x16,%edx
  8023a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023a9:	f6 c2 01             	test   $0x1,%dl
  8023ac:	74 15                	je     8023c3 <malloc+0xf7>
  8023ae:	89 c2                	mov    %eax,%edx
  8023b0:	c1 ea 0c             	shr    $0xc,%edx
  8023b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8023ba:	f6 c2 01             	test   $0x1,%dl
  8023bd:	0f 85 c5 00 00 00    	jne    802488 <malloc+0x1bc>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8023c3:	05 00 10 00 00       	add    $0x1000,%eax
  8023c8:	39 c8                	cmp    %ecx,%eax
  8023ca:	72 c6                	jb     802392 <malloc+0xc6>
  8023cc:	eb 79                	jmp    802447 <malloc+0x17b>
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  8023ce:	be 00 00 00 08       	mov    $0x8000000,%esi
  8023d3:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
			if (++nwrap == 2)
  8023d7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8023db:	75 a9                	jne    802386 <malloc+0xba>
  8023dd:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8023e4:	00 00 08 
				return 0;	/* out of address space */
  8023e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ec:	e9 b3 00 00 00       	jmp    8024a4 <malloc+0x1d8>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8023f1:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  8023f7:	39 df                	cmp    %ebx,%edi
  8023f9:	19 c0                	sbb    %eax,%eax
  8023fb:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  802400:	83 ec 04             	sub    $0x4,%esp
  802403:	83 c8 07             	or     $0x7,%eax
  802406:	50                   	push   %eax
  802407:	03 15 18 50 80 00    	add    0x805018,%edx
  80240d:	52                   	push   %edx
  80240e:	6a 00                	push   $0x0
  802410:	e8 38 ec ff ff       	call   80104d <sys_page_alloc>
  802415:	83 c4 10             	add    $0x10,%esp
  802418:	85 c0                	test   %eax,%eax
  80241a:	78 20                	js     80243c <malloc+0x170>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  80241c:	89 fe                	mov    %edi,%esi
  80241e:	eb 3a                	jmp    80245a <malloc+0x18e>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  802420:	83 ec 08             	sub    $0x8,%esp
  802423:	89 f0                	mov    %esi,%eax
  802425:	03 05 18 50 80 00    	add    0x805018,%eax
  80242b:	50                   	push   %eax
  80242c:	6a 00                	push   $0x0
  80242e:	e8 9f ec ff ff       	call   8010d2 <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802433:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  802439:	83 c4 10             	add    $0x10,%esp
  80243c:	85 f6                	test   %esi,%esi
  80243e:	79 e0                	jns    802420 <malloc+0x154>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  802440:	b8 00 00 00 00       	mov    $0x0,%eax
  802445:	eb 5d                	jmp    8024a4 <malloc+0x1d8>
  802447:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80244b:	74 08                	je     802455 <malloc+0x189>
  80244d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802450:	a3 18 50 80 00       	mov    %eax,0x805018

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  802455:	be 00 00 00 00       	mov    $0x0,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  80245a:	89 f2                	mov    %esi,%edx
  80245c:	39 f3                	cmp    %esi,%ebx
  80245e:	77 91                	ja     8023f1 <malloc+0x125>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  802460:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802465:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  80246c:	00 
	v = mptr;
	mptr += n;
  80246d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802470:	01 c2                	add    %eax,%edx
  802472:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  802478:	eb 2a                	jmp    8024a4 <malloc+0x1d8>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  80247a:	b8 00 00 00 00       	mov    $0x0,%eax
  80247f:	eb 23                	jmp    8024a4 <malloc+0x1d8>
  802481:	b8 00 00 00 00       	mov    $0x0,%eax
  802486:	eb 1c                	jmp    8024a4 <malloc+0x1d8>
  802488:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
  80248e:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
  802492:	89 c6                	mov    %eax,%esi
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  802494:	3d 00 00 00 10       	cmp    $0x10000000,%eax
  802499:	0f 85 e7 fe ff ff    	jne    802386 <malloc+0xba>
  80249f:	e9 2a ff ff ff       	jmp    8023ce <malloc+0x102>
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  8024a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a7:	5b                   	pop    %ebx
  8024a8:	5e                   	pop    %esi
  8024a9:	5f                   	pop    %edi
  8024aa:	5d                   	pop    %ebp
  8024ab:	c3                   	ret    

008024ac <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024ac:	55                   	push   %ebp
  8024ad:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024af:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b4:	5d                   	pop    %ebp
  8024b5:	c3                   	ret    

008024b6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024b6:	55                   	push   %ebp
  8024b7:	89 e5                	mov    %esp,%ebp
  8024b9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8024bc:	68 7d 30 80 00       	push   $0x80307d
  8024c1:	ff 75 0c             	pushl  0xc(%ebp)
  8024c4:	e8 81 e7 ff ff       	call   800c4a <strcpy>
	return 0;
}
  8024c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8024ce:	c9                   	leave  
  8024cf:	c3                   	ret    

008024d0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	57                   	push   %edi
  8024d4:	56                   	push   %esi
  8024d5:	53                   	push   %ebx
  8024d6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024dc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024e1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024e7:	eb 2d                	jmp    802516 <devcons_write+0x46>
		m = n - tot;
  8024e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024ec:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8024ee:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024f1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8024f6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024f9:	83 ec 04             	sub    $0x4,%esp
  8024fc:	53                   	push   %ebx
  8024fd:	03 45 0c             	add    0xc(%ebp),%eax
  802500:	50                   	push   %eax
  802501:	57                   	push   %edi
  802502:	e8 d5 e8 ff ff       	call   800ddc <memmove>
		sys_cputs(buf, m);
  802507:	83 c4 08             	add    $0x8,%esp
  80250a:	53                   	push   %ebx
  80250b:	57                   	push   %edi
  80250c:	e8 80 ea ff ff       	call   800f91 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802511:	01 de                	add    %ebx,%esi
  802513:	83 c4 10             	add    $0x10,%esp
  802516:	89 f0                	mov    %esi,%eax
  802518:	3b 75 10             	cmp    0x10(%ebp),%esi
  80251b:	72 cc                	jb     8024e9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80251d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802520:	5b                   	pop    %ebx
  802521:	5e                   	pop    %esi
  802522:	5f                   	pop    %edi
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    

00802525 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	83 ec 08             	sub    $0x8,%esp
  80252b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802530:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802534:	74 2a                	je     802560 <devcons_read+0x3b>
  802536:	eb 05                	jmp    80253d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802538:	e8 f1 ea ff ff       	call   80102e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80253d:	e8 6d ea ff ff       	call   800faf <sys_cgetc>
  802542:	85 c0                	test   %eax,%eax
  802544:	74 f2                	je     802538 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802546:	85 c0                	test   %eax,%eax
  802548:	78 16                	js     802560 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80254a:	83 f8 04             	cmp    $0x4,%eax
  80254d:	74 0c                	je     80255b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80254f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802552:	88 02                	mov    %al,(%edx)
	return 1;
  802554:	b8 01 00 00 00       	mov    $0x1,%eax
  802559:	eb 05                	jmp    802560 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80255b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802560:	c9                   	leave  
  802561:	c3                   	ret    

00802562 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802562:	55                   	push   %ebp
  802563:	89 e5                	mov    %esp,%ebp
  802565:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802568:	8b 45 08             	mov    0x8(%ebp),%eax
  80256b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80256e:	6a 01                	push   $0x1
  802570:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802573:	50                   	push   %eax
  802574:	e8 18 ea ff ff       	call   800f91 <sys_cputs>
}
  802579:	83 c4 10             	add    $0x10,%esp
  80257c:	c9                   	leave  
  80257d:	c3                   	ret    

0080257e <getchar>:

int
getchar(void)
{
  80257e:	55                   	push   %ebp
  80257f:	89 e5                	mov    %esp,%ebp
  802581:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802584:	6a 01                	push   $0x1
  802586:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802589:	50                   	push   %eax
  80258a:	6a 00                	push   $0x0
  80258c:	e8 a8 ef ff ff       	call   801539 <read>
	if (r < 0)
  802591:	83 c4 10             	add    $0x10,%esp
  802594:	85 c0                	test   %eax,%eax
  802596:	78 0f                	js     8025a7 <getchar+0x29>
		return r;
	if (r < 1)
  802598:	85 c0                	test   %eax,%eax
  80259a:	7e 06                	jle    8025a2 <getchar+0x24>
		return -E_EOF;
	return c;
  80259c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025a0:	eb 05                	jmp    8025a7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025a2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025a7:	c9                   	leave  
  8025a8:	c3                   	ret    

008025a9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025a9:	55                   	push   %ebp
  8025aa:	89 e5                	mov    %esp,%ebp
  8025ac:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b2:	50                   	push   %eax
  8025b3:	ff 75 08             	pushl  0x8(%ebp)
  8025b6:	e8 18 ed ff ff       	call   8012d3 <fd_lookup>
  8025bb:	83 c4 10             	add    $0x10,%esp
  8025be:	85 c0                	test   %eax,%eax
  8025c0:	78 11                	js     8025d3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c5:	8b 15 78 40 80 00    	mov    0x804078,%edx
  8025cb:	39 10                	cmp    %edx,(%eax)
  8025cd:	0f 94 c0             	sete   %al
  8025d0:	0f b6 c0             	movzbl %al,%eax
}
  8025d3:	c9                   	leave  
  8025d4:	c3                   	ret    

008025d5 <opencons>:

int
opencons(void)
{
  8025d5:	55                   	push   %ebp
  8025d6:	89 e5                	mov    %esp,%ebp
  8025d8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025de:	50                   	push   %eax
  8025df:	e8 a0 ec ff ff       	call   801284 <fd_alloc>
  8025e4:	83 c4 10             	add    $0x10,%esp
		return r;
  8025e7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025e9:	85 c0                	test   %eax,%eax
  8025eb:	78 3e                	js     80262b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025ed:	83 ec 04             	sub    $0x4,%esp
  8025f0:	68 07 04 00 00       	push   $0x407
  8025f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8025f8:	6a 00                	push   $0x0
  8025fa:	e8 4e ea ff ff       	call   80104d <sys_page_alloc>
  8025ff:	83 c4 10             	add    $0x10,%esp
		return r;
  802602:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802604:	85 c0                	test   %eax,%eax
  802606:	78 23                	js     80262b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802608:	8b 15 78 40 80 00    	mov    0x804078,%edx
  80260e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802611:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802613:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802616:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80261d:	83 ec 0c             	sub    $0xc,%esp
  802620:	50                   	push   %eax
  802621:	e8 37 ec ff ff       	call   80125d <fd2num>
  802626:	89 c2                	mov    %eax,%edx
  802628:	83 c4 10             	add    $0x10,%esp
}
  80262b:	89 d0                	mov    %edx,%eax
  80262d:	c9                   	leave  
  80262e:	c3                   	ret    

0080262f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80262f:	55                   	push   %ebp
  802630:	89 e5                	mov    %esp,%ebp
  802632:	56                   	push   %esi
  802633:	53                   	push   %ebx
  802634:	8b 75 08             	mov    0x8(%ebp),%esi
  802637:	8b 45 0c             	mov    0xc(%ebp),%eax
  80263a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80263d:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80263f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802644:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802647:	83 ec 0c             	sub    $0xc,%esp
  80264a:	50                   	push   %eax
  80264b:	e8 ad eb ff ff       	call   8011fd <sys_ipc_recv>

	if (from_env_store != NULL)
  802650:	83 c4 10             	add    $0x10,%esp
  802653:	85 f6                	test   %esi,%esi
  802655:	74 14                	je     80266b <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802657:	ba 00 00 00 00       	mov    $0x0,%edx
  80265c:	85 c0                	test   %eax,%eax
  80265e:	78 09                	js     802669 <ipc_recv+0x3a>
  802660:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802666:	8b 52 74             	mov    0x74(%edx),%edx
  802669:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80266b:	85 db                	test   %ebx,%ebx
  80266d:	74 14                	je     802683 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  80266f:	ba 00 00 00 00       	mov    $0x0,%edx
  802674:	85 c0                	test   %eax,%eax
  802676:	78 09                	js     802681 <ipc_recv+0x52>
  802678:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  80267e:	8b 52 78             	mov    0x78(%edx),%edx
  802681:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802683:	85 c0                	test   %eax,%eax
  802685:	78 08                	js     80268f <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802687:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80268c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80268f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802692:	5b                   	pop    %ebx
  802693:	5e                   	pop    %esi
  802694:	5d                   	pop    %ebp
  802695:	c3                   	ret    

00802696 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802696:	55                   	push   %ebp
  802697:	89 e5                	mov    %esp,%ebp
  802699:	57                   	push   %edi
  80269a:	56                   	push   %esi
  80269b:	53                   	push   %ebx
  80269c:	83 ec 0c             	sub    $0xc,%esp
  80269f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8026a8:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8026aa:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026af:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8026b2:	ff 75 14             	pushl  0x14(%ebp)
  8026b5:	53                   	push   %ebx
  8026b6:	56                   	push   %esi
  8026b7:	57                   	push   %edi
  8026b8:	e8 1d eb ff ff       	call   8011da <sys_ipc_try_send>

		if (err < 0) {
  8026bd:	83 c4 10             	add    $0x10,%esp
  8026c0:	85 c0                	test   %eax,%eax
  8026c2:	79 1e                	jns    8026e2 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8026c4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026c7:	75 07                	jne    8026d0 <ipc_send+0x3a>
				sys_yield();
  8026c9:	e8 60 e9 ff ff       	call   80102e <sys_yield>
  8026ce:	eb e2                	jmp    8026b2 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8026d0:	50                   	push   %eax
  8026d1:	68 89 30 80 00       	push   $0x803089
  8026d6:	6a 49                	push   $0x49
  8026d8:	68 96 30 80 00       	push   $0x803096
  8026dd:	e8 0a df ff ff       	call   8005ec <_panic>
		}

	} while (err < 0);

}
  8026e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026e5:	5b                   	pop    %ebx
  8026e6:	5e                   	pop    %esi
  8026e7:	5f                   	pop    %edi
  8026e8:	5d                   	pop    %ebp
  8026e9:	c3                   	ret    

008026ea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026ea:	55                   	push   %ebp
  8026eb:	89 e5                	mov    %esp,%ebp
  8026ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026f0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026f5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026f8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026fe:	8b 52 50             	mov    0x50(%edx),%edx
  802701:	39 ca                	cmp    %ecx,%edx
  802703:	75 0d                	jne    802712 <ipc_find_env+0x28>
			return envs[i].env_id;
  802705:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802708:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80270d:	8b 40 48             	mov    0x48(%eax),%eax
  802710:	eb 0f                	jmp    802721 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802712:	83 c0 01             	add    $0x1,%eax
  802715:	3d 00 04 00 00       	cmp    $0x400,%eax
  80271a:	75 d9                	jne    8026f5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80271c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802721:	5d                   	pop    %ebp
  802722:	c3                   	ret    

00802723 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802723:	55                   	push   %ebp
  802724:	89 e5                	mov    %esp,%ebp
  802726:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802729:	89 d0                	mov    %edx,%eax
  80272b:	c1 e8 16             	shr    $0x16,%eax
  80272e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802735:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80273a:	f6 c1 01             	test   $0x1,%cl
  80273d:	74 1d                	je     80275c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80273f:	c1 ea 0c             	shr    $0xc,%edx
  802742:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802749:	f6 c2 01             	test   $0x1,%dl
  80274c:	74 0e                	je     80275c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80274e:	c1 ea 0c             	shr    $0xc,%edx
  802751:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802758:	ef 
  802759:	0f b7 c0             	movzwl %ax,%eax
}
  80275c:	5d                   	pop    %ebp
  80275d:	c3                   	ret    
  80275e:	66 90                	xchg   %ax,%ax

00802760 <__udivdi3>:
  802760:	55                   	push   %ebp
  802761:	57                   	push   %edi
  802762:	56                   	push   %esi
  802763:	53                   	push   %ebx
  802764:	83 ec 1c             	sub    $0x1c,%esp
  802767:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80276b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80276f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802773:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802777:	85 f6                	test   %esi,%esi
  802779:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80277d:	89 ca                	mov    %ecx,%edx
  80277f:	89 f8                	mov    %edi,%eax
  802781:	75 3d                	jne    8027c0 <__udivdi3+0x60>
  802783:	39 cf                	cmp    %ecx,%edi
  802785:	0f 87 c5 00 00 00    	ja     802850 <__udivdi3+0xf0>
  80278b:	85 ff                	test   %edi,%edi
  80278d:	89 fd                	mov    %edi,%ebp
  80278f:	75 0b                	jne    80279c <__udivdi3+0x3c>
  802791:	b8 01 00 00 00       	mov    $0x1,%eax
  802796:	31 d2                	xor    %edx,%edx
  802798:	f7 f7                	div    %edi
  80279a:	89 c5                	mov    %eax,%ebp
  80279c:	89 c8                	mov    %ecx,%eax
  80279e:	31 d2                	xor    %edx,%edx
  8027a0:	f7 f5                	div    %ebp
  8027a2:	89 c1                	mov    %eax,%ecx
  8027a4:	89 d8                	mov    %ebx,%eax
  8027a6:	89 cf                	mov    %ecx,%edi
  8027a8:	f7 f5                	div    %ebp
  8027aa:	89 c3                	mov    %eax,%ebx
  8027ac:	89 d8                	mov    %ebx,%eax
  8027ae:	89 fa                	mov    %edi,%edx
  8027b0:	83 c4 1c             	add    $0x1c,%esp
  8027b3:	5b                   	pop    %ebx
  8027b4:	5e                   	pop    %esi
  8027b5:	5f                   	pop    %edi
  8027b6:	5d                   	pop    %ebp
  8027b7:	c3                   	ret    
  8027b8:	90                   	nop
  8027b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	39 ce                	cmp    %ecx,%esi
  8027c2:	77 74                	ja     802838 <__udivdi3+0xd8>
  8027c4:	0f bd fe             	bsr    %esi,%edi
  8027c7:	83 f7 1f             	xor    $0x1f,%edi
  8027ca:	0f 84 98 00 00 00    	je     802868 <__udivdi3+0x108>
  8027d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027d5:	89 f9                	mov    %edi,%ecx
  8027d7:	89 c5                	mov    %eax,%ebp
  8027d9:	29 fb                	sub    %edi,%ebx
  8027db:	d3 e6                	shl    %cl,%esi
  8027dd:	89 d9                	mov    %ebx,%ecx
  8027df:	d3 ed                	shr    %cl,%ebp
  8027e1:	89 f9                	mov    %edi,%ecx
  8027e3:	d3 e0                	shl    %cl,%eax
  8027e5:	09 ee                	or     %ebp,%esi
  8027e7:	89 d9                	mov    %ebx,%ecx
  8027e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027ed:	89 d5                	mov    %edx,%ebp
  8027ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027f3:	d3 ed                	shr    %cl,%ebp
  8027f5:	89 f9                	mov    %edi,%ecx
  8027f7:	d3 e2                	shl    %cl,%edx
  8027f9:	89 d9                	mov    %ebx,%ecx
  8027fb:	d3 e8                	shr    %cl,%eax
  8027fd:	09 c2                	or     %eax,%edx
  8027ff:	89 d0                	mov    %edx,%eax
  802801:	89 ea                	mov    %ebp,%edx
  802803:	f7 f6                	div    %esi
  802805:	89 d5                	mov    %edx,%ebp
  802807:	89 c3                	mov    %eax,%ebx
  802809:	f7 64 24 0c          	mull   0xc(%esp)
  80280d:	39 d5                	cmp    %edx,%ebp
  80280f:	72 10                	jb     802821 <__udivdi3+0xc1>
  802811:	8b 74 24 08          	mov    0x8(%esp),%esi
  802815:	89 f9                	mov    %edi,%ecx
  802817:	d3 e6                	shl    %cl,%esi
  802819:	39 c6                	cmp    %eax,%esi
  80281b:	73 07                	jae    802824 <__udivdi3+0xc4>
  80281d:	39 d5                	cmp    %edx,%ebp
  80281f:	75 03                	jne    802824 <__udivdi3+0xc4>
  802821:	83 eb 01             	sub    $0x1,%ebx
  802824:	31 ff                	xor    %edi,%edi
  802826:	89 d8                	mov    %ebx,%eax
  802828:	89 fa                	mov    %edi,%edx
  80282a:	83 c4 1c             	add    $0x1c,%esp
  80282d:	5b                   	pop    %ebx
  80282e:	5e                   	pop    %esi
  80282f:	5f                   	pop    %edi
  802830:	5d                   	pop    %ebp
  802831:	c3                   	ret    
  802832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802838:	31 ff                	xor    %edi,%edi
  80283a:	31 db                	xor    %ebx,%ebx
  80283c:	89 d8                	mov    %ebx,%eax
  80283e:	89 fa                	mov    %edi,%edx
  802840:	83 c4 1c             	add    $0x1c,%esp
  802843:	5b                   	pop    %ebx
  802844:	5e                   	pop    %esi
  802845:	5f                   	pop    %edi
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    
  802848:	90                   	nop
  802849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802850:	89 d8                	mov    %ebx,%eax
  802852:	f7 f7                	div    %edi
  802854:	31 ff                	xor    %edi,%edi
  802856:	89 c3                	mov    %eax,%ebx
  802858:	89 d8                	mov    %ebx,%eax
  80285a:	89 fa                	mov    %edi,%edx
  80285c:	83 c4 1c             	add    $0x1c,%esp
  80285f:	5b                   	pop    %ebx
  802860:	5e                   	pop    %esi
  802861:	5f                   	pop    %edi
  802862:	5d                   	pop    %ebp
  802863:	c3                   	ret    
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	39 ce                	cmp    %ecx,%esi
  80286a:	72 0c                	jb     802878 <__udivdi3+0x118>
  80286c:	31 db                	xor    %ebx,%ebx
  80286e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802872:	0f 87 34 ff ff ff    	ja     8027ac <__udivdi3+0x4c>
  802878:	bb 01 00 00 00       	mov    $0x1,%ebx
  80287d:	e9 2a ff ff ff       	jmp    8027ac <__udivdi3+0x4c>
  802882:	66 90                	xchg   %ax,%ax
  802884:	66 90                	xchg   %ax,%ax
  802886:	66 90                	xchg   %ax,%ax
  802888:	66 90                	xchg   %ax,%ax
  80288a:	66 90                	xchg   %ax,%ax
  80288c:	66 90                	xchg   %ax,%ax
  80288e:	66 90                	xchg   %ax,%ax

00802890 <__umoddi3>:
  802890:	55                   	push   %ebp
  802891:	57                   	push   %edi
  802892:	56                   	push   %esi
  802893:	53                   	push   %ebx
  802894:	83 ec 1c             	sub    $0x1c,%esp
  802897:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80289b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80289f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028a7:	85 d2                	test   %edx,%edx
  8028a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028b1:	89 f3                	mov    %esi,%ebx
  8028b3:	89 3c 24             	mov    %edi,(%esp)
  8028b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028ba:	75 1c                	jne    8028d8 <__umoddi3+0x48>
  8028bc:	39 f7                	cmp    %esi,%edi
  8028be:	76 50                	jbe    802910 <__umoddi3+0x80>
  8028c0:	89 c8                	mov    %ecx,%eax
  8028c2:	89 f2                	mov    %esi,%edx
  8028c4:	f7 f7                	div    %edi
  8028c6:	89 d0                	mov    %edx,%eax
  8028c8:	31 d2                	xor    %edx,%edx
  8028ca:	83 c4 1c             	add    $0x1c,%esp
  8028cd:	5b                   	pop    %ebx
  8028ce:	5e                   	pop    %esi
  8028cf:	5f                   	pop    %edi
  8028d0:	5d                   	pop    %ebp
  8028d1:	c3                   	ret    
  8028d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028d8:	39 f2                	cmp    %esi,%edx
  8028da:	89 d0                	mov    %edx,%eax
  8028dc:	77 52                	ja     802930 <__umoddi3+0xa0>
  8028de:	0f bd ea             	bsr    %edx,%ebp
  8028e1:	83 f5 1f             	xor    $0x1f,%ebp
  8028e4:	75 5a                	jne    802940 <__umoddi3+0xb0>
  8028e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028ea:	0f 82 e0 00 00 00    	jb     8029d0 <__umoddi3+0x140>
  8028f0:	39 0c 24             	cmp    %ecx,(%esp)
  8028f3:	0f 86 d7 00 00 00    	jbe    8029d0 <__umoddi3+0x140>
  8028f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802901:	83 c4 1c             	add    $0x1c,%esp
  802904:	5b                   	pop    %ebx
  802905:	5e                   	pop    %esi
  802906:	5f                   	pop    %edi
  802907:	5d                   	pop    %ebp
  802908:	c3                   	ret    
  802909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802910:	85 ff                	test   %edi,%edi
  802912:	89 fd                	mov    %edi,%ebp
  802914:	75 0b                	jne    802921 <__umoddi3+0x91>
  802916:	b8 01 00 00 00       	mov    $0x1,%eax
  80291b:	31 d2                	xor    %edx,%edx
  80291d:	f7 f7                	div    %edi
  80291f:	89 c5                	mov    %eax,%ebp
  802921:	89 f0                	mov    %esi,%eax
  802923:	31 d2                	xor    %edx,%edx
  802925:	f7 f5                	div    %ebp
  802927:	89 c8                	mov    %ecx,%eax
  802929:	f7 f5                	div    %ebp
  80292b:	89 d0                	mov    %edx,%eax
  80292d:	eb 99                	jmp    8028c8 <__umoddi3+0x38>
  80292f:	90                   	nop
  802930:	89 c8                	mov    %ecx,%eax
  802932:	89 f2                	mov    %esi,%edx
  802934:	83 c4 1c             	add    $0x1c,%esp
  802937:	5b                   	pop    %ebx
  802938:	5e                   	pop    %esi
  802939:	5f                   	pop    %edi
  80293a:	5d                   	pop    %ebp
  80293b:	c3                   	ret    
  80293c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802940:	8b 34 24             	mov    (%esp),%esi
  802943:	bf 20 00 00 00       	mov    $0x20,%edi
  802948:	89 e9                	mov    %ebp,%ecx
  80294a:	29 ef                	sub    %ebp,%edi
  80294c:	d3 e0                	shl    %cl,%eax
  80294e:	89 f9                	mov    %edi,%ecx
  802950:	89 f2                	mov    %esi,%edx
  802952:	d3 ea                	shr    %cl,%edx
  802954:	89 e9                	mov    %ebp,%ecx
  802956:	09 c2                	or     %eax,%edx
  802958:	89 d8                	mov    %ebx,%eax
  80295a:	89 14 24             	mov    %edx,(%esp)
  80295d:	89 f2                	mov    %esi,%edx
  80295f:	d3 e2                	shl    %cl,%edx
  802961:	89 f9                	mov    %edi,%ecx
  802963:	89 54 24 04          	mov    %edx,0x4(%esp)
  802967:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80296b:	d3 e8                	shr    %cl,%eax
  80296d:	89 e9                	mov    %ebp,%ecx
  80296f:	89 c6                	mov    %eax,%esi
  802971:	d3 e3                	shl    %cl,%ebx
  802973:	89 f9                	mov    %edi,%ecx
  802975:	89 d0                	mov    %edx,%eax
  802977:	d3 e8                	shr    %cl,%eax
  802979:	89 e9                	mov    %ebp,%ecx
  80297b:	09 d8                	or     %ebx,%eax
  80297d:	89 d3                	mov    %edx,%ebx
  80297f:	89 f2                	mov    %esi,%edx
  802981:	f7 34 24             	divl   (%esp)
  802984:	89 d6                	mov    %edx,%esi
  802986:	d3 e3                	shl    %cl,%ebx
  802988:	f7 64 24 04          	mull   0x4(%esp)
  80298c:	39 d6                	cmp    %edx,%esi
  80298e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802992:	89 d1                	mov    %edx,%ecx
  802994:	89 c3                	mov    %eax,%ebx
  802996:	72 08                	jb     8029a0 <__umoddi3+0x110>
  802998:	75 11                	jne    8029ab <__umoddi3+0x11b>
  80299a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80299e:	73 0b                	jae    8029ab <__umoddi3+0x11b>
  8029a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029a4:	1b 14 24             	sbb    (%esp),%edx
  8029a7:	89 d1                	mov    %edx,%ecx
  8029a9:	89 c3                	mov    %eax,%ebx
  8029ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029af:	29 da                	sub    %ebx,%edx
  8029b1:	19 ce                	sbb    %ecx,%esi
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 f0                	mov    %esi,%eax
  8029b7:	d3 e0                	shl    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	d3 ea                	shr    %cl,%edx
  8029bd:	89 e9                	mov    %ebp,%ecx
  8029bf:	d3 ee                	shr    %cl,%esi
  8029c1:	09 d0                	or     %edx,%eax
  8029c3:	89 f2                	mov    %esi,%edx
  8029c5:	83 c4 1c             	add    $0x1c,%esp
  8029c8:	5b                   	pop    %ebx
  8029c9:	5e                   	pop    %esi
  8029ca:	5f                   	pop    %edi
  8029cb:	5d                   	pop    %ebp
  8029cc:	c3                   	ret    
  8029cd:	8d 76 00             	lea    0x0(%esi),%esi
  8029d0:	29 f9                	sub    %edi,%ecx
  8029d2:	19 d6                	sbb    %edx,%esi
  8029d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029dc:	e9 18 ff ff ff       	jmp    8028f9 <__umoddi3+0x69>
