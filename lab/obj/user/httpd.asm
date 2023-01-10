
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
  80003a:	68 40 2a 80 00       	push   $0x802a40
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
  800069:	e8 0d 15 00 00       	call   80157b <read>
  80006e:	83 c4 10             	add    $0x10,%esp
  800071:	85 c0                	test   %eax,%eax
  800073:	79 17                	jns    80008c <handle_client+0x3e>
			panic("failed to read");
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	68 44 2a 80 00       	push   $0x802a44
  80007d:	68 04 01 00 00       	push   $0x104
  800082:	68 53 2a 80 00       	push   $0x802a53
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
  8000a4:	68 60 2a 80 00       	push   $0x802a60
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
  8000e1:	e8 cc 1e 00 00       	call   801fb2 <malloc>
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
  80011f:	e8 8e 1e 00 00       	call   801fb2 <malloc>
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
  80013c:	68 65 2a 80 00       	push   $0x802a65
  800141:	68 e2 00 00 00       	push   $0xe2
  800146:	68 53 2a 80 00       	push   $0x802a53
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
  800178:	68 b4 2a 80 00       	push   $0x802ab4
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
  800196:	e8 ba 14 00 00       	call   801655 <write>
  80019b:	83 c4 10             	add    $0x10,%esp
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a4:	e8 5b 1d 00 00       	call   801f04 <free>
	free(req->version);
  8001a9:	83 c4 04             	add    $0x4,%esp
  8001ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001af:	e8 50 1d 00 00       	call   801f04 <free>

		// no keep alive
		break;
	}

	close(sock);
  8001b4:	89 1c 24             	mov    %ebx,(%esp)
  8001b7:	e8 83 12 00 00       	call   80143f <close>
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
  8001d0:	c7 05 20 40 80 00 7f 	movl   $0x802a7f,0x804020
  8001d7:	2a 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8001da:	6a 06                	push   $0x6
  8001dc:	6a 01                	push   $0x1
  8001de:	6a 02                	push   $0x2
  8001e0:	e8 a7 1a 00 00       	call   801c8c <socket>
  8001e5:	89 c6                	mov    %eax,%esi
  8001e7:	83 c4 10             	add    $0x10,%esp
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	79 0a                	jns    8001f8 <umain+0x31>
		die("Failed to create socket");
  8001ee:	b8 86 2a 80 00       	mov    $0x802a86,%eax
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
  800232:	e8 c3 19 00 00       	call   801bfa <bind>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	85 c0                	test   %eax,%eax
  80023c:	79 0a                	jns    800248 <umain+0x81>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  80023e:	b8 30 2b 80 00       	mov    $0x802b30,%eax
  800243:	e8 eb fd ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	6a 05                	push   $0x5
  80024d:	56                   	push   %esi
  80024e:	e8 16 1a 00 00       	call   801c69 <listen>
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	85 c0                	test   %eax,%eax
  800258:	79 0a                	jns    800264 <umain+0x9d>
		die("Failed to listen on server socket");
  80025a:	b8 54 2b 80 00       	mov    $0x802b54,%eax
  80025f:	e8 cf fd ff ff       	call   800033 <die>

	cprintf("Waiting for http connections...\n");
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	68 78 2b 80 00       	push   $0x802b78
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
  800287:	e8 37 19 00 00       	call   801bc3 <accept>
  80028c:	89 c3                	mov    %eax,%ebx
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	85 c0                	test   %eax,%eax
  800293:	79 0a                	jns    80029f <umain+0xd8>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  800295:	b8 9c 2b 80 00       	mov    $0x802b9c,%eax
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
  8005d8:	e8 8d 0e 00 00       	call   80146a <close_all>
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
  80060a:	68 f0 2b 80 00       	push   $0x802bf0
  80060f:	e8 b1 00 00 00       	call   8006c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800614:	83 c4 18             	add    $0x18,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 10             	pushl  0x10(%ebp)
  80061b:	e8 54 00 00 00       	call   800674 <vcprintf>
	cprintf("\n");
  800620:	c7 04 24 b5 30 80 00 	movl   $0x8030b5,(%esp)
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
  800728:	e8 73 20 00 00       	call   8027a0 <__udivdi3>
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
  80076b:	e8 60 21 00 00       	call   8028d0 <__umoddi3>
  800770:	83 c4 14             	add    $0x14,%esp
  800773:	0f be 80 13 2c 80 00 	movsbl 0x802c13(%eax),%eax
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
  80086f:	ff 24 85 60 2d 80 00 	jmp    *0x802d60(,%eax,4)
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
  800933:	8b 14 85 c0 2e 80 00 	mov    0x802ec0(,%eax,4),%edx
  80093a:	85 d2                	test   %edx,%edx
  80093c:	75 18                	jne    800956 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80093e:	50                   	push   %eax
  80093f:	68 2b 2c 80 00       	push   $0x802c2b
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
  800957:	68 f5 2f 80 00       	push   $0x802ff5
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
  80097b:	b8 24 2c 80 00       	mov    $0x802c24,%eax
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
  800ff6:	68 1f 2f 80 00       	push   $0x802f1f
  800ffb:	6a 23                	push   $0x23
  800ffd:	68 3c 2f 80 00       	push   $0x802f3c
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
  801077:	68 1f 2f 80 00       	push   $0x802f1f
  80107c:	6a 23                	push   $0x23
  80107e:	68 3c 2f 80 00       	push   $0x802f3c
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
  8010b9:	68 1f 2f 80 00       	push   $0x802f1f
  8010be:	6a 23                	push   $0x23
  8010c0:	68 3c 2f 80 00       	push   $0x802f3c
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
  8010fb:	68 1f 2f 80 00       	push   $0x802f1f
  801100:	6a 23                	push   $0x23
  801102:	68 3c 2f 80 00       	push   $0x802f3c
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
  80113d:	68 1f 2f 80 00       	push   $0x802f1f
  801142:	6a 23                	push   $0x23
  801144:	68 3c 2f 80 00       	push   $0x802f3c
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
  80117f:	68 1f 2f 80 00       	push   $0x802f1f
  801184:	6a 23                	push   $0x23
  801186:	68 3c 2f 80 00       	push   $0x802f3c
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
  8011c1:	68 1f 2f 80 00       	push   $0x802f1f
  8011c6:	6a 23                	push   $0x23
  8011c8:	68 3c 2f 80 00       	push   $0x802f3c
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
  801225:	68 1f 2f 80 00       	push   $0x802f1f
  80122a:	6a 23                	push   $0x23
  80122c:	68 3c 2f 80 00       	push   $0x802f3c
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

0080125d <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126b:	b8 0f 00 00 00       	mov    $0xf,%eax
  801270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801273:	8b 55 08             	mov    0x8(%ebp),%edx
  801276:	89 df                	mov    %ebx,%edi
  801278:	89 de                	mov    %ebx,%esi
  80127a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80127c:	85 c0                	test   %eax,%eax
  80127e:	7e 17                	jle    801297 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801280:	83 ec 0c             	sub    $0xc,%esp
  801283:	50                   	push   %eax
  801284:	6a 0f                	push   $0xf
  801286:	68 1f 2f 80 00       	push   $0x802f1f
  80128b:	6a 23                	push   $0x23
  80128d:	68 3c 2f 80 00       	push   $0x802f3c
  801292:	e8 55 f3 ff ff       	call   8005ec <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  801297:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129a:	5b                   	pop    %ebx
  80129b:	5e                   	pop    %esi
  80129c:	5f                   	pop    %edi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8012aa:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b5:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012bf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	c1 ea 16             	shr    $0x16,%edx
  8012d6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012dd:	f6 c2 01             	test   $0x1,%dl
  8012e0:	74 11                	je     8012f3 <fd_alloc+0x2d>
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	c1 ea 0c             	shr    $0xc,%edx
  8012e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ee:	f6 c2 01             	test   $0x1,%dl
  8012f1:	75 09                	jne    8012fc <fd_alloc+0x36>
			*fd_store = fd;
  8012f3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fa:	eb 17                	jmp    801313 <fd_alloc+0x4d>
  8012fc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801301:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801306:	75 c9                	jne    8012d1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801308:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80130e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    

00801315 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80131b:	83 f8 1f             	cmp    $0x1f,%eax
  80131e:	77 36                	ja     801356 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801320:	c1 e0 0c             	shl    $0xc,%eax
  801323:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801328:	89 c2                	mov    %eax,%edx
  80132a:	c1 ea 16             	shr    $0x16,%edx
  80132d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801334:	f6 c2 01             	test   $0x1,%dl
  801337:	74 24                	je     80135d <fd_lookup+0x48>
  801339:	89 c2                	mov    %eax,%edx
  80133b:	c1 ea 0c             	shr    $0xc,%edx
  80133e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801345:	f6 c2 01             	test   $0x1,%dl
  801348:	74 1a                	je     801364 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80134a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134d:	89 02                	mov    %eax,(%edx)
	return 0;
  80134f:	b8 00 00 00 00       	mov    $0x0,%eax
  801354:	eb 13                	jmp    801369 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801356:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135b:	eb 0c                	jmp    801369 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80135d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801362:	eb 05                	jmp    801369 <fd_lookup+0x54>
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801374:	ba c8 2f 80 00       	mov    $0x802fc8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801379:	eb 13                	jmp    80138e <dev_lookup+0x23>
  80137b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80137e:	39 08                	cmp    %ecx,(%eax)
  801380:	75 0c                	jne    80138e <dev_lookup+0x23>
			*dev = devtab[i];
  801382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801385:	89 01                	mov    %eax,(%ecx)
			return 0;
  801387:	b8 00 00 00 00       	mov    $0x0,%eax
  80138c:	eb 2e                	jmp    8013bc <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80138e:	8b 02                	mov    (%edx),%eax
  801390:	85 c0                	test   %eax,%eax
  801392:	75 e7                	jne    80137b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801394:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801399:	8b 40 48             	mov    0x48(%eax),%eax
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	51                   	push   %ecx
  8013a0:	50                   	push   %eax
  8013a1:	68 4c 2f 80 00       	push   $0x802f4c
  8013a6:	e8 1a f3 ff ff       	call   8006c5 <cprintf>
	*dev = 0;
  8013ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 10             	sub    $0x10,%esp
  8013c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013d6:	c1 e8 0c             	shr    $0xc,%eax
  8013d9:	50                   	push   %eax
  8013da:	e8 36 ff ff ff       	call   801315 <fd_lookup>
  8013df:	83 c4 08             	add    $0x8,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 05                	js     8013eb <fd_close+0x2d>
	    || fd != fd2)
  8013e6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013e9:	74 0c                	je     8013f7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013eb:	84 db                	test   %bl,%bl
  8013ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f2:	0f 44 c2             	cmove  %edx,%eax
  8013f5:	eb 41                	jmp    801438 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	ff 36                	pushl  (%esi)
  801400:	e8 66 ff ff ff       	call   80136b <dev_lookup>
  801405:	89 c3                	mov    %eax,%ebx
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 1a                	js     801428 <fd_close+0x6a>
		if (dev->dev_close)
  80140e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801411:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801414:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801419:	85 c0                	test   %eax,%eax
  80141b:	74 0b                	je     801428 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80141d:	83 ec 0c             	sub    $0xc,%esp
  801420:	56                   	push   %esi
  801421:	ff d0                	call   *%eax
  801423:	89 c3                	mov    %eax,%ebx
  801425:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	56                   	push   %esi
  80142c:	6a 00                	push   $0x0
  80142e:	e8 9f fc ff ff       	call   8010d2 <sys_page_unmap>
	return r;
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	89 d8                	mov    %ebx,%eax
}
  801438:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	ff 75 08             	pushl  0x8(%ebp)
  80144c:	e8 c4 fe ff ff       	call   801315 <fd_lookup>
  801451:	83 c4 08             	add    $0x8,%esp
  801454:	85 c0                	test   %eax,%eax
  801456:	78 10                	js     801468 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	6a 01                	push   $0x1
  80145d:	ff 75 f4             	pushl  -0xc(%ebp)
  801460:	e8 59 ff ff ff       	call   8013be <fd_close>
  801465:	83 c4 10             	add    $0x10,%esp
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <close_all>:

void
close_all(void)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801471:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801476:	83 ec 0c             	sub    $0xc,%esp
  801479:	53                   	push   %ebx
  80147a:	e8 c0 ff ff ff       	call   80143f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80147f:	83 c3 01             	add    $0x1,%ebx
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	83 fb 20             	cmp    $0x20,%ebx
  801488:	75 ec                	jne    801476 <close_all+0xc>
		close(i);
}
  80148a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	57                   	push   %edi
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	83 ec 2c             	sub    $0x2c,%esp
  801498:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80149b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80149e:	50                   	push   %eax
  80149f:	ff 75 08             	pushl  0x8(%ebp)
  8014a2:	e8 6e fe ff ff       	call   801315 <fd_lookup>
  8014a7:	83 c4 08             	add    $0x8,%esp
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	0f 88 c1 00 00 00    	js     801573 <dup+0xe4>
		return r;
	close(newfdnum);
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	56                   	push   %esi
  8014b6:	e8 84 ff ff ff       	call   80143f <close>

	newfd = INDEX2FD(newfdnum);
  8014bb:	89 f3                	mov    %esi,%ebx
  8014bd:	c1 e3 0c             	shl    $0xc,%ebx
  8014c0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014c6:	83 c4 04             	add    $0x4,%esp
  8014c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014cc:	e8 de fd ff ff       	call   8012af <fd2data>
  8014d1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014d3:	89 1c 24             	mov    %ebx,(%esp)
  8014d6:	e8 d4 fd ff ff       	call   8012af <fd2data>
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014e1:	89 f8                	mov    %edi,%eax
  8014e3:	c1 e8 16             	shr    $0x16,%eax
  8014e6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014ed:	a8 01                	test   $0x1,%al
  8014ef:	74 37                	je     801528 <dup+0x99>
  8014f1:	89 f8                	mov    %edi,%eax
  8014f3:	c1 e8 0c             	shr    $0xc,%eax
  8014f6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014fd:	f6 c2 01             	test   $0x1,%dl
  801500:	74 26                	je     801528 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801502:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801509:	83 ec 0c             	sub    $0xc,%esp
  80150c:	25 07 0e 00 00       	and    $0xe07,%eax
  801511:	50                   	push   %eax
  801512:	ff 75 d4             	pushl  -0x2c(%ebp)
  801515:	6a 00                	push   $0x0
  801517:	57                   	push   %edi
  801518:	6a 00                	push   $0x0
  80151a:	e8 71 fb ff ff       	call   801090 <sys_page_map>
  80151f:	89 c7                	mov    %eax,%edi
  801521:	83 c4 20             	add    $0x20,%esp
  801524:	85 c0                	test   %eax,%eax
  801526:	78 2e                	js     801556 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801528:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80152b:	89 d0                	mov    %edx,%eax
  80152d:	c1 e8 0c             	shr    $0xc,%eax
  801530:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	25 07 0e 00 00       	and    $0xe07,%eax
  80153f:	50                   	push   %eax
  801540:	53                   	push   %ebx
  801541:	6a 00                	push   $0x0
  801543:	52                   	push   %edx
  801544:	6a 00                	push   $0x0
  801546:	e8 45 fb ff ff       	call   801090 <sys_page_map>
  80154b:	89 c7                	mov    %eax,%edi
  80154d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801550:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801552:	85 ff                	test   %edi,%edi
  801554:	79 1d                	jns    801573 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801556:	83 ec 08             	sub    $0x8,%esp
  801559:	53                   	push   %ebx
  80155a:	6a 00                	push   $0x0
  80155c:	e8 71 fb ff ff       	call   8010d2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801561:	83 c4 08             	add    $0x8,%esp
  801564:	ff 75 d4             	pushl  -0x2c(%ebp)
  801567:	6a 00                	push   $0x0
  801569:	e8 64 fb ff ff       	call   8010d2 <sys_page_unmap>
	return r;
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	89 f8                	mov    %edi,%eax
}
  801573:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	53                   	push   %ebx
  80157f:	83 ec 14             	sub    $0x14,%esp
  801582:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801585:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	53                   	push   %ebx
  80158a:	e8 86 fd ff ff       	call   801315 <fd_lookup>
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	89 c2                	mov    %eax,%edx
  801594:	85 c0                	test   %eax,%eax
  801596:	78 6d                	js     801605 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159e:	50                   	push   %eax
  80159f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a2:	ff 30                	pushl  (%eax)
  8015a4:	e8 c2 fd ff ff       	call   80136b <dev_lookup>
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 4c                	js     8015fc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015b3:	8b 42 08             	mov    0x8(%edx),%eax
  8015b6:	83 e0 03             	and    $0x3,%eax
  8015b9:	83 f8 01             	cmp    $0x1,%eax
  8015bc:	75 21                	jne    8015df <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015be:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8015c3:	8b 40 48             	mov    0x48(%eax),%eax
  8015c6:	83 ec 04             	sub    $0x4,%esp
  8015c9:	53                   	push   %ebx
  8015ca:	50                   	push   %eax
  8015cb:	68 8d 2f 80 00       	push   $0x802f8d
  8015d0:	e8 f0 f0 ff ff       	call   8006c5 <cprintf>
		return -E_INVAL;
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015dd:	eb 26                	jmp    801605 <read+0x8a>
	}
	if (!dev->dev_read)
  8015df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e2:	8b 40 08             	mov    0x8(%eax),%eax
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	74 17                	je     801600 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015e9:	83 ec 04             	sub    $0x4,%esp
  8015ec:	ff 75 10             	pushl  0x10(%ebp)
  8015ef:	ff 75 0c             	pushl  0xc(%ebp)
  8015f2:	52                   	push   %edx
  8015f3:	ff d0                	call   *%eax
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	eb 09                	jmp    801605 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	eb 05                	jmp    801605 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801600:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801605:	89 d0                	mov    %edx,%eax
  801607:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160a:	c9                   	leave  
  80160b:	c3                   	ret    

0080160c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	57                   	push   %edi
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	8b 7d 08             	mov    0x8(%ebp),%edi
  801618:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801620:	eb 21                	jmp    801643 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	89 f0                	mov    %esi,%eax
  801627:	29 d8                	sub    %ebx,%eax
  801629:	50                   	push   %eax
  80162a:	89 d8                	mov    %ebx,%eax
  80162c:	03 45 0c             	add    0xc(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	57                   	push   %edi
  801631:	e8 45 ff ff ff       	call   80157b <read>
		if (m < 0)
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 10                	js     80164d <readn+0x41>
			return m;
		if (m == 0)
  80163d:	85 c0                	test   %eax,%eax
  80163f:	74 0a                	je     80164b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801641:	01 c3                	add    %eax,%ebx
  801643:	39 f3                	cmp    %esi,%ebx
  801645:	72 db                	jb     801622 <readn+0x16>
  801647:	89 d8                	mov    %ebx,%eax
  801649:	eb 02                	jmp    80164d <readn+0x41>
  80164b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80164d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801650:	5b                   	pop    %ebx
  801651:	5e                   	pop    %esi
  801652:	5f                   	pop    %edi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	53                   	push   %ebx
  801659:	83 ec 14             	sub    $0x14,%esp
  80165c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	53                   	push   %ebx
  801664:	e8 ac fc ff ff       	call   801315 <fd_lookup>
  801669:	83 c4 08             	add    $0x8,%esp
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 68                	js     8016da <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	ff 30                	pushl  (%eax)
  80167e:	e8 e8 fc ff ff       	call   80136b <dev_lookup>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 47                	js     8016d1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801691:	75 21                	jne    8016b4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801693:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801698:	8b 40 48             	mov    0x48(%eax),%eax
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	53                   	push   %ebx
  80169f:	50                   	push   %eax
  8016a0:	68 a9 2f 80 00       	push   $0x802fa9
  8016a5:	e8 1b f0 ff ff       	call   8006c5 <cprintf>
		return -E_INVAL;
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b2:	eb 26                	jmp    8016da <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ba:	85 d2                	test   %edx,%edx
  8016bc:	74 17                	je     8016d5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016be:	83 ec 04             	sub    $0x4,%esp
  8016c1:	ff 75 10             	pushl  0x10(%ebp)
  8016c4:	ff 75 0c             	pushl  0xc(%ebp)
  8016c7:	50                   	push   %eax
  8016c8:	ff d2                	call   *%edx
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	eb 09                	jmp    8016da <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d1:	89 c2                	mov    %eax,%edx
  8016d3:	eb 05                	jmp    8016da <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016da:	89 d0                	mov    %edx,%eax
  8016dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016e7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ea:	50                   	push   %eax
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 22 fc ff ff       	call   801315 <fd_lookup>
  8016f3:	83 c4 08             	add    $0x8,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 0e                	js     801708 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801700:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801703:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	53                   	push   %ebx
  80170e:	83 ec 14             	sub    $0x14,%esp
  801711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	53                   	push   %ebx
  801719:	e8 f7 fb ff ff       	call   801315 <fd_lookup>
  80171e:	83 c4 08             	add    $0x8,%esp
  801721:	89 c2                	mov    %eax,%edx
  801723:	85 c0                	test   %eax,%eax
  801725:	78 65                	js     80178c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801731:	ff 30                	pushl  (%eax)
  801733:	e8 33 fc ff ff       	call   80136b <dev_lookup>
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 44                	js     801783 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801746:	75 21                	jne    801769 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801748:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80174d:	8b 40 48             	mov    0x48(%eax),%eax
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	53                   	push   %ebx
  801754:	50                   	push   %eax
  801755:	68 6c 2f 80 00       	push   $0x802f6c
  80175a:	e8 66 ef ff ff       	call   8006c5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801767:	eb 23                	jmp    80178c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176c:	8b 52 18             	mov    0x18(%edx),%edx
  80176f:	85 d2                	test   %edx,%edx
  801771:	74 14                	je     801787 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	ff 75 0c             	pushl  0xc(%ebp)
  801779:	50                   	push   %eax
  80177a:	ff d2                	call   *%edx
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	eb 09                	jmp    80178c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801783:	89 c2                	mov    %eax,%edx
  801785:	eb 05                	jmp    80178c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801787:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80178c:	89 d0                	mov    %edx,%eax
  80178e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 14             	sub    $0x14,%esp
  80179a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a0:	50                   	push   %eax
  8017a1:	ff 75 08             	pushl  0x8(%ebp)
  8017a4:	e8 6c fb ff ff       	call   801315 <fd_lookup>
  8017a9:	83 c4 08             	add    $0x8,%esp
  8017ac:	89 c2                	mov    %eax,%edx
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 58                	js     80180a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	ff 30                	pushl  (%eax)
  8017be:	e8 a8 fb ff ff       	call   80136b <dev_lookup>
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 37                	js     801801 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017cd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017d1:	74 32                	je     801805 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017d3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017d6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017dd:	00 00 00 
	stat->st_isdir = 0;
  8017e0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017e7:	00 00 00 
	stat->st_dev = dev;
  8017ea:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	53                   	push   %ebx
  8017f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f7:	ff 50 14             	call   *0x14(%eax)
  8017fa:	89 c2                	mov    %eax,%edx
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	eb 09                	jmp    80180a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801801:	89 c2                	mov    %eax,%edx
  801803:	eb 05                	jmp    80180a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801805:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80180a:	89 d0                	mov    %edx,%eax
  80180c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	6a 00                	push   $0x0
  80181b:	ff 75 08             	pushl  0x8(%ebp)
  80181e:	e8 d6 01 00 00       	call   8019f9 <open>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 1b                	js     801847 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	ff 75 0c             	pushl  0xc(%ebp)
  801832:	50                   	push   %eax
  801833:	e8 5b ff ff ff       	call   801793 <fstat>
  801838:	89 c6                	mov    %eax,%esi
	close(fd);
  80183a:	89 1c 24             	mov    %ebx,(%esp)
  80183d:	e8 fd fb ff ff       	call   80143f <close>
	return r;
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	89 f0                	mov    %esi,%eax
}
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	89 c6                	mov    %eax,%esi
  801855:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801857:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  80185e:	75 12                	jne    801872 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801860:	83 ec 0c             	sub    $0xc,%esp
  801863:	6a 01                	push   $0x1
  801865:	e8 c2 0e 00 00       	call   80272c <ipc_find_env>
  80186a:	a3 10 50 80 00       	mov    %eax,0x805010
  80186f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801872:	6a 07                	push   $0x7
  801874:	68 00 60 80 00       	push   $0x806000
  801879:	56                   	push   %esi
  80187a:	ff 35 10 50 80 00    	pushl  0x805010
  801880:	e8 53 0e 00 00       	call   8026d8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801885:	83 c4 0c             	add    $0xc,%esp
  801888:	6a 00                	push   $0x0
  80188a:	53                   	push   %ebx
  80188b:	6a 00                	push   $0x0
  80188d:	e8 df 0d 00 00       	call   802671 <ipc_recv>
}
  801892:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801895:	5b                   	pop    %ebx
  801896:	5e                   	pop    %esi
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8018aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ad:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8018bc:	e8 8d ff ff ff       	call   80184e <fsipc>
}
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cf:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8018d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018de:	e8 6b ff ff ff       	call   80184e <fsipc>
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 04             	sub    $0x4,%esp
  8018ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f5:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	b8 05 00 00 00       	mov    $0x5,%eax
  801904:	e8 45 ff ff ff       	call   80184e <fsipc>
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 2c                	js     801939 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	68 00 60 80 00       	push   $0x806000
  801915:	53                   	push   %ebx
  801916:	e8 2f f3 ff ff       	call   800c4a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80191b:	a1 80 60 80 00       	mov    0x806080,%eax
  801920:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801926:	a1 84 60 80 00       	mov    0x806084,%eax
  80192b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801939:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 0c             	sub    $0xc,%esp
  801944:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801947:	8b 55 08             	mov    0x8(%ebp),%edx
  80194a:	8b 52 0c             	mov    0xc(%edx),%edx
  80194d:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801953:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801958:	50                   	push   %eax
  801959:	ff 75 0c             	pushl  0xc(%ebp)
  80195c:	68 08 60 80 00       	push   $0x806008
  801961:	e8 76 f4 ff ff       	call   800ddc <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801966:	ba 00 00 00 00       	mov    $0x0,%edx
  80196b:	b8 04 00 00 00       	mov    $0x4,%eax
  801970:	e8 d9 fe ff ff       	call   80184e <fsipc>

}
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	56                   	push   %esi
  80197b:	53                   	push   %ebx
  80197c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	8b 40 0c             	mov    0xc(%eax),%eax
  801985:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80198a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801990:	ba 00 00 00 00       	mov    $0x0,%edx
  801995:	b8 03 00 00 00       	mov    $0x3,%eax
  80199a:	e8 af fe ff ff       	call   80184e <fsipc>
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 4b                	js     8019f0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019a5:	39 c6                	cmp    %eax,%esi
  8019a7:	73 16                	jae    8019bf <devfile_read+0x48>
  8019a9:	68 dc 2f 80 00       	push   $0x802fdc
  8019ae:	68 e3 2f 80 00       	push   $0x802fe3
  8019b3:	6a 7c                	push   $0x7c
  8019b5:	68 f8 2f 80 00       	push   $0x802ff8
  8019ba:	e8 2d ec ff ff       	call   8005ec <_panic>
	assert(r <= PGSIZE);
  8019bf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019c4:	7e 16                	jle    8019dc <devfile_read+0x65>
  8019c6:	68 03 30 80 00       	push   $0x803003
  8019cb:	68 e3 2f 80 00       	push   $0x802fe3
  8019d0:	6a 7d                	push   $0x7d
  8019d2:	68 f8 2f 80 00       	push   $0x802ff8
  8019d7:	e8 10 ec ff ff       	call   8005ec <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019dc:	83 ec 04             	sub    $0x4,%esp
  8019df:	50                   	push   %eax
  8019e0:	68 00 60 80 00       	push   $0x806000
  8019e5:	ff 75 0c             	pushl  0xc(%ebp)
  8019e8:	e8 ef f3 ff ff       	call   800ddc <memmove>
	return r;
  8019ed:	83 c4 10             	add    $0x10,%esp
}
  8019f0:	89 d8                	mov    %ebx,%eax
  8019f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 20             	sub    $0x20,%esp
  801a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a03:	53                   	push   %ebx
  801a04:	e8 08 f2 ff ff       	call   800c11 <strlen>
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a11:	7f 67                	jg     801a7a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a19:	50                   	push   %eax
  801a1a:	e8 a7 f8 ff ff       	call   8012c6 <fd_alloc>
  801a1f:	83 c4 10             	add    $0x10,%esp
		return r;
  801a22:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 57                	js     801a7f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	53                   	push   %ebx
  801a2c:	68 00 60 80 00       	push   $0x806000
  801a31:	e8 14 f2 ff ff       	call   800c4a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a39:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a41:	b8 01 00 00 00       	mov    $0x1,%eax
  801a46:	e8 03 fe ff ff       	call   80184e <fsipc>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	79 14                	jns    801a68 <open+0x6f>
		fd_close(fd, 0);
  801a54:	83 ec 08             	sub    $0x8,%esp
  801a57:	6a 00                	push   $0x0
  801a59:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5c:	e8 5d f9 ff ff       	call   8013be <fd_close>
		return r;
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	89 da                	mov    %ebx,%edx
  801a66:	eb 17                	jmp    801a7f <open+0x86>
	}

	return fd2num(fd);
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6e:	e8 2c f8 ff ff       	call   80129f <fd2num>
  801a73:	89 c2                	mov    %eax,%edx
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	eb 05                	jmp    801a7f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a7a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a7f:	89 d0                	mov    %edx,%eax
  801a81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a91:	b8 08 00 00 00       	mov    $0x8,%eax
  801a96:	e8 b3 fd ff ff       	call   80184e <fsipc>
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aa3:	68 0f 30 80 00       	push   $0x80300f
  801aa8:	ff 75 0c             	pushl  0xc(%ebp)
  801aab:	e8 9a f1 ff ff       	call   800c4a <strcpy>
	return 0;
}
  801ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	53                   	push   %ebx
  801abb:	83 ec 10             	sub    $0x10,%esp
  801abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ac1:	53                   	push   %ebx
  801ac2:	e8 9e 0c 00 00       	call   802765 <pageref>
  801ac7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801aca:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801acf:	83 f8 01             	cmp    $0x1,%eax
  801ad2:	75 10                	jne    801ae4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	ff 73 0c             	pushl  0xc(%ebx)
  801ada:	e8 c0 02 00 00       	call   801d9f <nsipc_close>
  801adf:	89 c2                	mov    %eax,%edx
  801ae1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ae4:	89 d0                	mov    %edx,%eax
  801ae6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    

00801aeb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801af1:	6a 00                	push   $0x0
  801af3:	ff 75 10             	pushl  0x10(%ebp)
  801af6:	ff 75 0c             	pushl  0xc(%ebp)
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	ff 70 0c             	pushl  0xc(%eax)
  801aff:	e8 78 03 00 00       	call   801e7c <nsipc_send>
}
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b0c:	6a 00                	push   $0x0
  801b0e:	ff 75 10             	pushl  0x10(%ebp)
  801b11:	ff 75 0c             	pushl  0xc(%ebp)
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	ff 70 0c             	pushl  0xc(%eax)
  801b1a:	e8 f1 02 00 00       	call   801e10 <nsipc_recv>
}
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b27:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b2a:	52                   	push   %edx
  801b2b:	50                   	push   %eax
  801b2c:	e8 e4 f7 ff ff       	call   801315 <fd_lookup>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 17                	js     801b4f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3b:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  801b41:	39 08                	cmp    %ecx,(%eax)
  801b43:	75 05                	jne    801b4a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b45:	8b 40 0c             	mov    0xc(%eax),%eax
  801b48:	eb 05                	jmp    801b4f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b4a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 1c             	sub    $0x1c,%esp
  801b59:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5e:	50                   	push   %eax
  801b5f:	e8 62 f7 ff ff       	call   8012c6 <fd_alloc>
  801b64:	89 c3                	mov    %eax,%ebx
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 1b                	js     801b88 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b6d:	83 ec 04             	sub    $0x4,%esp
  801b70:	68 07 04 00 00       	push   $0x407
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	6a 00                	push   $0x0
  801b7a:	e8 ce f4 ff ff       	call   80104d <sys_page_alloc>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	79 10                	jns    801b98 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	56                   	push   %esi
  801b8c:	e8 0e 02 00 00       	call   801d9f <nsipc_close>
		return r;
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	eb 24                	jmp    801bbc <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b98:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bad:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bb0:	83 ec 0c             	sub    $0xc,%esp
  801bb3:	50                   	push   %eax
  801bb4:	e8 e6 f6 ff ff       	call   80129f <fd2num>
  801bb9:	83 c4 10             	add    $0x10,%esp
}
  801bbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	e8 50 ff ff ff       	call   801b21 <fd2sockid>
		return r;
  801bd1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	78 1f                	js     801bf6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bd7:	83 ec 04             	sub    $0x4,%esp
  801bda:	ff 75 10             	pushl  0x10(%ebp)
  801bdd:	ff 75 0c             	pushl  0xc(%ebp)
  801be0:	50                   	push   %eax
  801be1:	e8 12 01 00 00       	call   801cf8 <nsipc_accept>
  801be6:	83 c4 10             	add    $0x10,%esp
		return r;
  801be9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801beb:	85 c0                	test   %eax,%eax
  801bed:	78 07                	js     801bf6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bef:	e8 5d ff ff ff       	call   801b51 <alloc_sockfd>
  801bf4:	89 c1                	mov    %eax,%ecx
}
  801bf6:	89 c8                	mov    %ecx,%eax
  801bf8:	c9                   	leave  
  801bf9:	c3                   	ret    

00801bfa <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c00:	8b 45 08             	mov    0x8(%ebp),%eax
  801c03:	e8 19 ff ff ff       	call   801b21 <fd2sockid>
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 12                	js     801c1e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	ff 75 10             	pushl  0x10(%ebp)
  801c12:	ff 75 0c             	pushl  0xc(%ebp)
  801c15:	50                   	push   %eax
  801c16:	e8 2d 01 00 00       	call   801d48 <nsipc_bind>
  801c1b:	83 c4 10             	add    $0x10,%esp
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <shutdown>:

int
shutdown(int s, int how)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	e8 f3 fe ff ff       	call   801b21 <fd2sockid>
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 0f                	js     801c41 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c32:	83 ec 08             	sub    $0x8,%esp
  801c35:	ff 75 0c             	pushl  0xc(%ebp)
  801c38:	50                   	push   %eax
  801c39:	e8 3f 01 00 00       	call   801d7d <nsipc_shutdown>
  801c3e:	83 c4 10             	add    $0x10,%esp
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	e8 d0 fe ff ff       	call   801b21 <fd2sockid>
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 12                	js     801c67 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c55:	83 ec 04             	sub    $0x4,%esp
  801c58:	ff 75 10             	pushl  0x10(%ebp)
  801c5b:	ff 75 0c             	pushl  0xc(%ebp)
  801c5e:	50                   	push   %eax
  801c5f:	e8 55 01 00 00       	call   801db9 <nsipc_connect>
  801c64:	83 c4 10             	add    $0x10,%esp
}
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <listen>:

int
listen(int s, int backlog)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	e8 aa fe ff ff       	call   801b21 <fd2sockid>
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 0f                	js     801c8a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c7b:	83 ec 08             	sub    $0x8,%esp
  801c7e:	ff 75 0c             	pushl  0xc(%ebp)
  801c81:	50                   	push   %eax
  801c82:	e8 67 01 00 00       	call   801dee <nsipc_listen>
  801c87:	83 c4 10             	add    $0x10,%esp
}
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c92:	ff 75 10             	pushl  0x10(%ebp)
  801c95:	ff 75 0c             	pushl  0xc(%ebp)
  801c98:	ff 75 08             	pushl  0x8(%ebp)
  801c9b:	e8 3a 02 00 00       	call   801eda <nsipc_socket>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	78 05                	js     801cac <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ca7:	e8 a5 fe ff ff       	call   801b51 <alloc_sockfd>
}
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    

00801cae <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	53                   	push   %ebx
  801cb2:	83 ec 04             	sub    $0x4,%esp
  801cb5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cb7:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  801cbe:	75 12                	jne    801cd2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cc0:	83 ec 0c             	sub    $0xc,%esp
  801cc3:	6a 02                	push   $0x2
  801cc5:	e8 62 0a 00 00       	call   80272c <ipc_find_env>
  801cca:	a3 14 50 80 00       	mov    %eax,0x805014
  801ccf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cd2:	6a 07                	push   $0x7
  801cd4:	68 00 70 80 00       	push   $0x807000
  801cd9:	53                   	push   %ebx
  801cda:	ff 35 14 50 80 00    	pushl  0x805014
  801ce0:	e8 f3 09 00 00       	call   8026d8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ce5:	83 c4 0c             	add    $0xc,%esp
  801ce8:	6a 00                	push   $0x0
  801cea:	6a 00                	push   $0x0
  801cec:	6a 00                	push   $0x0
  801cee:	e8 7e 09 00 00       	call   802671 <ipc_recv>
}
  801cf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf6:	c9                   	leave  
  801cf7:	c3                   	ret    

00801cf8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	56                   	push   %esi
  801cfc:	53                   	push   %ebx
  801cfd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d00:	8b 45 08             	mov    0x8(%ebp),%eax
  801d03:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d08:	8b 06                	mov    (%esi),%eax
  801d0a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d0f:	b8 01 00 00 00       	mov    $0x1,%eax
  801d14:	e8 95 ff ff ff       	call   801cae <nsipc>
  801d19:	89 c3                	mov    %eax,%ebx
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 20                	js     801d3f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	ff 35 10 70 80 00    	pushl  0x807010
  801d28:	68 00 70 80 00       	push   $0x807000
  801d2d:	ff 75 0c             	pushl  0xc(%ebp)
  801d30:	e8 a7 f0 ff ff       	call   800ddc <memmove>
		*addrlen = ret->ret_addrlen;
  801d35:	a1 10 70 80 00       	mov    0x807010,%eax
  801d3a:	89 06                	mov    %eax,(%esi)
  801d3c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d3f:	89 d8                	mov    %ebx,%eax
  801d41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    

00801d48 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	53                   	push   %ebx
  801d4c:	83 ec 08             	sub    $0x8,%esp
  801d4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d52:	8b 45 08             	mov    0x8(%ebp),%eax
  801d55:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d5a:	53                   	push   %ebx
  801d5b:	ff 75 0c             	pushl  0xc(%ebp)
  801d5e:	68 04 70 80 00       	push   $0x807004
  801d63:	e8 74 f0 ff ff       	call   800ddc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d68:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801d6e:	b8 02 00 00 00       	mov    $0x2,%eax
  801d73:	e8 36 ff ff ff       	call   801cae <nsipc>
}
  801d78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d93:	b8 03 00 00 00       	mov    $0x3,%eax
  801d98:	e8 11 ff ff ff       	call   801cae <nsipc>
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <nsipc_close>:

int
nsipc_close(int s)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801da5:	8b 45 08             	mov    0x8(%ebp),%eax
  801da8:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801dad:	b8 04 00 00 00       	mov    $0x4,%eax
  801db2:	e8 f7 fe ff ff       	call   801cae <nsipc>
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	53                   	push   %ebx
  801dbd:	83 ec 08             	sub    $0x8,%esp
  801dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc6:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dcb:	53                   	push   %ebx
  801dcc:	ff 75 0c             	pushl  0xc(%ebp)
  801dcf:	68 04 70 80 00       	push   $0x807004
  801dd4:	e8 03 f0 ff ff       	call   800ddc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dd9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801ddf:	b8 05 00 00 00       	mov    $0x5,%eax
  801de4:	e8 c5 fe ff ff       	call   801cae <nsipc>
}
  801de9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801df4:	8b 45 08             	mov    0x8(%ebp),%eax
  801df7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dff:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801e04:	b8 06 00 00 00       	mov    $0x6,%eax
  801e09:	e8 a0 fe ff ff       	call   801cae <nsipc>
}
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	56                   	push   %esi
  801e14:	53                   	push   %ebx
  801e15:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801e20:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801e26:	8b 45 14             	mov    0x14(%ebp),%eax
  801e29:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e2e:	b8 07 00 00 00       	mov    $0x7,%eax
  801e33:	e8 76 fe ff ff       	call   801cae <nsipc>
  801e38:	89 c3                	mov    %eax,%ebx
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	78 35                	js     801e73 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e3e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e43:	7f 04                	jg     801e49 <nsipc_recv+0x39>
  801e45:	39 c6                	cmp    %eax,%esi
  801e47:	7d 16                	jge    801e5f <nsipc_recv+0x4f>
  801e49:	68 1b 30 80 00       	push   $0x80301b
  801e4e:	68 e3 2f 80 00       	push   $0x802fe3
  801e53:	6a 62                	push   $0x62
  801e55:	68 30 30 80 00       	push   $0x803030
  801e5a:	e8 8d e7 ff ff       	call   8005ec <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	50                   	push   %eax
  801e63:	68 00 70 80 00       	push   $0x807000
  801e68:	ff 75 0c             	pushl  0xc(%ebp)
  801e6b:	e8 6c ef ff ff       	call   800ddc <memmove>
  801e70:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e73:	89 d8                	mov    %ebx,%eax
  801e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	53                   	push   %ebx
  801e80:	83 ec 04             	sub    $0x4,%esp
  801e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e86:	8b 45 08             	mov    0x8(%ebp),%eax
  801e89:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e8e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e94:	7e 16                	jle    801eac <nsipc_send+0x30>
  801e96:	68 3c 30 80 00       	push   $0x80303c
  801e9b:	68 e3 2f 80 00       	push   $0x802fe3
  801ea0:	6a 6d                	push   $0x6d
  801ea2:	68 30 30 80 00       	push   $0x803030
  801ea7:	e8 40 e7 ff ff       	call   8005ec <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801eac:	83 ec 04             	sub    $0x4,%esp
  801eaf:	53                   	push   %ebx
  801eb0:	ff 75 0c             	pushl  0xc(%ebp)
  801eb3:	68 0c 70 80 00       	push   $0x80700c
  801eb8:	e8 1f ef ff ff       	call   800ddc <memmove>
	nsipcbuf.send.req_size = size;
  801ebd:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801ec3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801ecb:	b8 08 00 00 00       	mov    $0x8,%eax
  801ed0:	e8 d9 fd ff ff       	call   801cae <nsipc>
}
  801ed5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eeb:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801ef0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801ef8:	b8 09 00 00 00       	mov    $0x9,%eax
  801efd:	e8 ac fd ff ff       	call   801cae <nsipc>
}
  801f02:	c9                   	leave  
  801f03:	c3                   	ret    

00801f04 <free>:
	return v;
}

void
free(void *v)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	53                   	push   %ebx
  801f08:	83 ec 04             	sub    $0x4,%esp
  801f0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  801f0e:	85 db                	test   %ebx,%ebx
  801f10:	0f 84 97 00 00 00    	je     801fad <free+0xa9>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  801f16:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  801f1c:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  801f21:	76 16                	jbe    801f39 <free+0x35>
  801f23:	68 48 30 80 00       	push   $0x803048
  801f28:	68 e3 2f 80 00       	push   $0x802fe3
  801f2d:	6a 7a                	push   $0x7a
  801f2f:	68 78 30 80 00       	push   $0x803078
  801f34:	e8 b3 e6 ff ff       	call   8005ec <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  801f39:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  801f3f:	eb 3a                	jmp    801f7b <free+0x77>
		sys_page_unmap(0, c);
  801f41:	83 ec 08             	sub    $0x8,%esp
  801f44:	53                   	push   %ebx
  801f45:	6a 00                	push   $0x0
  801f47:	e8 86 f1 ff ff       	call   8010d2 <sys_page_unmap>
		c += PGSIZE;
  801f4c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  801f52:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  801f60:	76 19                	jbe    801f7b <free+0x77>
  801f62:	68 85 30 80 00       	push   $0x803085
  801f67:	68 e3 2f 80 00       	push   $0x802fe3
  801f6c:	68 81 00 00 00       	push   $0x81
  801f71:	68 78 30 80 00       	push   $0x803078
  801f76:	e8 71 e6 ff ff       	call   8005ec <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  801f7b:	89 d8                	mov    %ebx,%eax
  801f7d:	c1 e8 0c             	shr    $0xc,%eax
  801f80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f87:	f6 c4 02             	test   $0x2,%ah
  801f8a:	75 b5                	jne    801f41 <free+0x3d>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  801f8c:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  801f92:	83 e8 01             	sub    $0x1,%eax
  801f95:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	75 0e                	jne    801fad <free+0xa9>
		sys_page_unmap(0, c);
  801f9f:	83 ec 08             	sub    $0x8,%esp
  801fa2:	53                   	push   %ebx
  801fa3:	6a 00                	push   $0x0
  801fa5:	e8 28 f1 ff ff       	call   8010d2 <sys_page_unmap>
  801faa:	83 c4 10             	add    $0x10,%esp
}
  801fad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb0:	c9                   	leave  
  801fb1:	c3                   	ret    

00801fb2 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	57                   	push   %edi
  801fb6:	56                   	push   %esi
  801fb7:	53                   	push   %ebx
  801fb8:	83 ec 1c             	sub    $0x1c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  801fbb:	a1 18 50 80 00       	mov    0x805018,%eax
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	75 22                	jne    801fe6 <malloc+0x34>
		mptr = mbegin;
  801fc4:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  801fcb:	00 00 08 

	n = ROUNDUP(n, 4);
  801fce:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd1:	83 c0 03             	add    $0x3,%eax
  801fd4:	83 e0 fc             	and    $0xfffffffc,%eax
  801fd7:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if (n >= MAXMALLOC)
  801fda:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  801fdf:	76 74                	jbe    802055 <malloc+0xa3>
  801fe1:	e9 7a 01 00 00       	jmp    802160 <malloc+0x1ae>
	void *v;

	if (mptr == 0)
		mptr = mbegin;

	n = ROUNDUP(n, 4);
  801fe6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801fe9:	8d 53 03             	lea    0x3(%ebx),%edx
  801fec:	83 e2 fc             	and    $0xfffffffc,%edx
  801fef:	89 55 dc             	mov    %edx,-0x24(%ebp)

	if (n >= MAXMALLOC)
  801ff2:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  801ff8:	0f 87 69 01 00 00    	ja     802167 <malloc+0x1b5>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  801ffe:	a9 ff 0f 00 00       	test   $0xfff,%eax
  802003:	74 50                	je     802055 <malloc+0xa3>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  802005:	89 c1                	mov    %eax,%ecx
  802007:	c1 e9 0c             	shr    $0xc,%ecx
  80200a:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  80200e:	c1 ea 0c             	shr    $0xc,%edx
  802011:	39 d1                	cmp    %edx,%ecx
  802013:	75 20                	jne    802035 <malloc+0x83>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  802015:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80201b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802021:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  802025:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802028:	01 c2                	add    %eax,%edx
  80202a:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  802030:	e9 55 01 00 00       	jmp    80218a <malloc+0x1d8>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  802035:	83 ec 0c             	sub    $0xc,%esp
  802038:	50                   	push   %eax
  802039:	e8 c6 fe ff ff       	call   801f04 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  80203e:	a1 18 50 80 00       	mov    0x805018,%eax
  802043:	05 00 10 00 00       	add    $0x1000,%eax
  802048:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80204d:	a3 18 50 80 00       	mov    %eax,0x805018
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	8b 35 18 50 80 00    	mov    0x805018,%esi
	return 1;
}

void*
malloc(size_t n)
{
  80205b:	c7 45 d8 02 00 00 00 	movl   $0x2,-0x28(%ebp)
  802062:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  802066:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802069:	8d 78 04             	lea    0x4(%eax),%edi
  80206c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80206f:	89 fb                	mov    %edi,%ebx
  802071:	8d 0c 37             	lea    (%edi,%esi,1),%ecx
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802074:	89 f0                	mov    %esi,%eax
  802076:	eb 36                	jmp    8020ae <malloc+0xfc>
		if (va >= (uintptr_t) mend
  802078:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  80207d:	0f 87 eb 00 00 00    	ja     80216e <malloc+0x1bc>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  802083:	89 c2                	mov    %eax,%edx
  802085:	c1 ea 16             	shr    $0x16,%edx
  802088:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80208f:	f6 c2 01             	test   $0x1,%dl
  802092:	74 15                	je     8020a9 <malloc+0xf7>
  802094:	89 c2                	mov    %eax,%edx
  802096:	c1 ea 0c             	shr    $0xc,%edx
  802099:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8020a0:	f6 c2 01             	test   $0x1,%dl
  8020a3:	0f 85 c5 00 00 00    	jne    80216e <malloc+0x1bc>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8020a9:	05 00 10 00 00       	add    $0x1000,%eax
  8020ae:	39 c8                	cmp    %ecx,%eax
  8020b0:	72 c6                	jb     802078 <malloc+0xc6>
  8020b2:	eb 79                	jmp    80212d <malloc+0x17b>
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  8020b4:	be 00 00 00 08       	mov    $0x8000000,%esi
  8020b9:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
			if (++nwrap == 2)
  8020bd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8020c1:	75 a9                	jne    80206c <malloc+0xba>
  8020c3:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8020ca:	00 00 08 
				return 0;	/* out of address space */
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d2:	e9 b3 00 00 00       	jmp    80218a <malloc+0x1d8>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8020d7:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  8020dd:	39 df                	cmp    %ebx,%edi
  8020df:	19 c0                	sbb    %eax,%eax
  8020e1:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8020e6:	83 ec 04             	sub    $0x4,%esp
  8020e9:	83 c8 07             	or     $0x7,%eax
  8020ec:	50                   	push   %eax
  8020ed:	03 15 18 50 80 00    	add    0x805018,%edx
  8020f3:	52                   	push   %edx
  8020f4:	6a 00                	push   $0x0
  8020f6:	e8 52 ef ff ff       	call   80104d <sys_page_alloc>
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 20                	js     802122 <malloc+0x170>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802102:	89 fe                	mov    %edi,%esi
  802104:	eb 3a                	jmp    802140 <malloc+0x18e>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  802106:	83 ec 08             	sub    $0x8,%esp
  802109:	89 f0                	mov    %esi,%eax
  80210b:	03 05 18 50 80 00    	add    0x805018,%eax
  802111:	50                   	push   %eax
  802112:	6a 00                	push   $0x0
  802114:	e8 b9 ef ff ff       	call   8010d2 <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802119:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	85 f6                	test   %esi,%esi
  802124:	79 e0                	jns    802106 <malloc+0x154>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  802126:	b8 00 00 00 00       	mov    $0x0,%eax
  80212b:	eb 5d                	jmp    80218a <malloc+0x1d8>
  80212d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802131:	74 08                	je     80213b <malloc+0x189>
  802133:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802136:	a3 18 50 80 00       	mov    %eax,0x805018

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  80213b:	be 00 00 00 00       	mov    $0x0,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802140:	89 f2                	mov    %esi,%edx
  802142:	39 f3                	cmp    %esi,%ebx
  802144:	77 91                	ja     8020d7 <malloc+0x125>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  802146:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  80214b:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  802152:	00 
	v = mptr;
	mptr += n;
  802153:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802156:	01 c2                	add    %eax,%edx
  802158:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  80215e:	eb 2a                	jmp    80218a <malloc+0x1d8>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  802160:	b8 00 00 00 00       	mov    $0x0,%eax
  802165:	eb 23                	jmp    80218a <malloc+0x1d8>
  802167:	b8 00 00 00 00       	mov    $0x0,%eax
  80216c:	eb 1c                	jmp    80218a <malloc+0x1d8>
  80216e:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
  802174:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
  802178:	89 c6                	mov    %eax,%esi
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  80217a:	3d 00 00 00 10       	cmp    $0x10000000,%eax
  80217f:	0f 85 e7 fe ff ff    	jne    80206c <malloc+0xba>
  802185:	e9 2a ff ff ff       	jmp    8020b4 <malloc+0x102>
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  80218a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    

00802192 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	56                   	push   %esi
  802196:	53                   	push   %ebx
  802197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80219a:	83 ec 0c             	sub    $0xc,%esp
  80219d:	ff 75 08             	pushl  0x8(%ebp)
  8021a0:	e8 0a f1 ff ff       	call   8012af <fd2data>
  8021a5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021a7:	83 c4 08             	add    $0x8,%esp
  8021aa:	68 9d 30 80 00       	push   $0x80309d
  8021af:	53                   	push   %ebx
  8021b0:	e8 95 ea ff ff       	call   800c4a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021b5:	8b 46 04             	mov    0x4(%esi),%eax
  8021b8:	2b 06                	sub    (%esi),%eax
  8021ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021c7:	00 00 00 
	stat->st_dev = &devpipe;
  8021ca:	c7 83 88 00 00 00 5c 	movl   $0x80405c,0x88(%ebx)
  8021d1:	40 80 00 
	return 0;
}
  8021d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021dc:	5b                   	pop    %ebx
  8021dd:	5e                   	pop    %esi
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    

008021e0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 0c             	sub    $0xc,%esp
  8021e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021ea:	53                   	push   %ebx
  8021eb:	6a 00                	push   $0x0
  8021ed:	e8 e0 ee ff ff       	call   8010d2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021f2:	89 1c 24             	mov    %ebx,(%esp)
  8021f5:	e8 b5 f0 ff ff       	call   8012af <fd2data>
  8021fa:	83 c4 08             	add    $0x8,%esp
  8021fd:	50                   	push   %eax
  8021fe:	6a 00                	push   $0x0
  802200:	e8 cd ee ff ff       	call   8010d2 <sys_page_unmap>
}
  802205:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802208:	c9                   	leave  
  802209:	c3                   	ret    

0080220a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	57                   	push   %edi
  80220e:	56                   	push   %esi
  80220f:	53                   	push   %ebx
  802210:	83 ec 1c             	sub    $0x1c,%esp
  802213:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802216:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802218:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80221d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802220:	83 ec 0c             	sub    $0xc,%esp
  802223:	ff 75 e0             	pushl  -0x20(%ebp)
  802226:	e8 3a 05 00 00       	call   802765 <pageref>
  80222b:	89 c3                	mov    %eax,%ebx
  80222d:	89 3c 24             	mov    %edi,(%esp)
  802230:	e8 30 05 00 00       	call   802765 <pageref>
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	39 c3                	cmp    %eax,%ebx
  80223a:	0f 94 c1             	sete   %cl
  80223d:	0f b6 c9             	movzbl %cl,%ecx
  802240:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802243:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802249:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80224c:	39 ce                	cmp    %ecx,%esi
  80224e:	74 1b                	je     80226b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802250:	39 c3                	cmp    %eax,%ebx
  802252:	75 c4                	jne    802218 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802254:	8b 42 58             	mov    0x58(%edx),%eax
  802257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80225a:	50                   	push   %eax
  80225b:	56                   	push   %esi
  80225c:	68 a4 30 80 00       	push   $0x8030a4
  802261:	e8 5f e4 ff ff       	call   8006c5 <cprintf>
  802266:	83 c4 10             	add    $0x10,%esp
  802269:	eb ad                	jmp    802218 <_pipeisclosed+0xe>
	}
}
  80226b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80226e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802271:	5b                   	pop    %ebx
  802272:	5e                   	pop    %esi
  802273:	5f                   	pop    %edi
  802274:	5d                   	pop    %ebp
  802275:	c3                   	ret    

00802276 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802276:	55                   	push   %ebp
  802277:	89 e5                	mov    %esp,%ebp
  802279:	57                   	push   %edi
  80227a:	56                   	push   %esi
  80227b:	53                   	push   %ebx
  80227c:	83 ec 28             	sub    $0x28,%esp
  80227f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802282:	56                   	push   %esi
  802283:	e8 27 f0 ff ff       	call   8012af <fd2data>
  802288:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80228a:	83 c4 10             	add    $0x10,%esp
  80228d:	bf 00 00 00 00       	mov    $0x0,%edi
  802292:	eb 4b                	jmp    8022df <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802294:	89 da                	mov    %ebx,%edx
  802296:	89 f0                	mov    %esi,%eax
  802298:	e8 6d ff ff ff       	call   80220a <_pipeisclosed>
  80229d:	85 c0                	test   %eax,%eax
  80229f:	75 48                	jne    8022e9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022a1:	e8 88 ed ff ff       	call   80102e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022a6:	8b 43 04             	mov    0x4(%ebx),%eax
  8022a9:	8b 0b                	mov    (%ebx),%ecx
  8022ab:	8d 51 20             	lea    0x20(%ecx),%edx
  8022ae:	39 d0                	cmp    %edx,%eax
  8022b0:	73 e2                	jae    802294 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022b5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022b9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022bc:	89 c2                	mov    %eax,%edx
  8022be:	c1 fa 1f             	sar    $0x1f,%edx
  8022c1:	89 d1                	mov    %edx,%ecx
  8022c3:	c1 e9 1b             	shr    $0x1b,%ecx
  8022c6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022c9:	83 e2 1f             	and    $0x1f,%edx
  8022cc:	29 ca                	sub    %ecx,%edx
  8022ce:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022d6:	83 c0 01             	add    $0x1,%eax
  8022d9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022dc:	83 c7 01             	add    $0x1,%edi
  8022df:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022e2:	75 c2                	jne    8022a6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8022e7:	eb 05                	jmp    8022ee <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022e9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f1:	5b                   	pop    %ebx
  8022f2:	5e                   	pop    %esi
  8022f3:	5f                   	pop    %edi
  8022f4:	5d                   	pop    %ebp
  8022f5:	c3                   	ret    

008022f6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	57                   	push   %edi
  8022fa:	56                   	push   %esi
  8022fb:	53                   	push   %ebx
  8022fc:	83 ec 18             	sub    $0x18,%esp
  8022ff:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802302:	57                   	push   %edi
  802303:	e8 a7 ef ff ff       	call   8012af <fd2data>
  802308:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80230a:	83 c4 10             	add    $0x10,%esp
  80230d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802312:	eb 3d                	jmp    802351 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802314:	85 db                	test   %ebx,%ebx
  802316:	74 04                	je     80231c <devpipe_read+0x26>
				return i;
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	eb 44                	jmp    802360 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80231c:	89 f2                	mov    %esi,%edx
  80231e:	89 f8                	mov    %edi,%eax
  802320:	e8 e5 fe ff ff       	call   80220a <_pipeisclosed>
  802325:	85 c0                	test   %eax,%eax
  802327:	75 32                	jne    80235b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802329:	e8 00 ed ff ff       	call   80102e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80232e:	8b 06                	mov    (%esi),%eax
  802330:	3b 46 04             	cmp    0x4(%esi),%eax
  802333:	74 df                	je     802314 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802335:	99                   	cltd   
  802336:	c1 ea 1b             	shr    $0x1b,%edx
  802339:	01 d0                	add    %edx,%eax
  80233b:	83 e0 1f             	and    $0x1f,%eax
  80233e:	29 d0                	sub    %edx,%eax
  802340:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802345:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802348:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80234b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80234e:	83 c3 01             	add    $0x1,%ebx
  802351:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802354:	75 d8                	jne    80232e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802356:	8b 45 10             	mov    0x10(%ebp),%eax
  802359:	eb 05                	jmp    802360 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80235b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802360:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    

00802368 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802368:	55                   	push   %ebp
  802369:	89 e5                	mov    %esp,%ebp
  80236b:	56                   	push   %esi
  80236c:	53                   	push   %ebx
  80236d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802373:	50                   	push   %eax
  802374:	e8 4d ef ff ff       	call   8012c6 <fd_alloc>
  802379:	83 c4 10             	add    $0x10,%esp
  80237c:	89 c2                	mov    %eax,%edx
  80237e:	85 c0                	test   %eax,%eax
  802380:	0f 88 2c 01 00 00    	js     8024b2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802386:	83 ec 04             	sub    $0x4,%esp
  802389:	68 07 04 00 00       	push   $0x407
  80238e:	ff 75 f4             	pushl  -0xc(%ebp)
  802391:	6a 00                	push   $0x0
  802393:	e8 b5 ec ff ff       	call   80104d <sys_page_alloc>
  802398:	83 c4 10             	add    $0x10,%esp
  80239b:	89 c2                	mov    %eax,%edx
  80239d:	85 c0                	test   %eax,%eax
  80239f:	0f 88 0d 01 00 00    	js     8024b2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023a5:	83 ec 0c             	sub    $0xc,%esp
  8023a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023ab:	50                   	push   %eax
  8023ac:	e8 15 ef ff ff       	call   8012c6 <fd_alloc>
  8023b1:	89 c3                	mov    %eax,%ebx
  8023b3:	83 c4 10             	add    $0x10,%esp
  8023b6:	85 c0                	test   %eax,%eax
  8023b8:	0f 88 e2 00 00 00    	js     8024a0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023be:	83 ec 04             	sub    $0x4,%esp
  8023c1:	68 07 04 00 00       	push   $0x407
  8023c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8023c9:	6a 00                	push   $0x0
  8023cb:	e8 7d ec ff ff       	call   80104d <sys_page_alloc>
  8023d0:	89 c3                	mov    %eax,%ebx
  8023d2:	83 c4 10             	add    $0x10,%esp
  8023d5:	85 c0                	test   %eax,%eax
  8023d7:	0f 88 c3 00 00 00    	js     8024a0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023dd:	83 ec 0c             	sub    $0xc,%esp
  8023e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e3:	e8 c7 ee ff ff       	call   8012af <fd2data>
  8023e8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ea:	83 c4 0c             	add    $0xc,%esp
  8023ed:	68 07 04 00 00       	push   $0x407
  8023f2:	50                   	push   %eax
  8023f3:	6a 00                	push   $0x0
  8023f5:	e8 53 ec ff ff       	call   80104d <sys_page_alloc>
  8023fa:	89 c3                	mov    %eax,%ebx
  8023fc:	83 c4 10             	add    $0x10,%esp
  8023ff:	85 c0                	test   %eax,%eax
  802401:	0f 88 89 00 00 00    	js     802490 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802407:	83 ec 0c             	sub    $0xc,%esp
  80240a:	ff 75 f0             	pushl  -0x10(%ebp)
  80240d:	e8 9d ee ff ff       	call   8012af <fd2data>
  802412:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802419:	50                   	push   %eax
  80241a:	6a 00                	push   $0x0
  80241c:	56                   	push   %esi
  80241d:	6a 00                	push   $0x0
  80241f:	e8 6c ec ff ff       	call   801090 <sys_page_map>
  802424:	89 c3                	mov    %eax,%ebx
  802426:	83 c4 20             	add    $0x20,%esp
  802429:	85 c0                	test   %eax,%eax
  80242b:	78 55                	js     802482 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80242d:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802433:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802436:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802438:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80243b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802442:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802448:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80244b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80244d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802450:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802457:	83 ec 0c             	sub    $0xc,%esp
  80245a:	ff 75 f4             	pushl  -0xc(%ebp)
  80245d:	e8 3d ee ff ff       	call   80129f <fd2num>
  802462:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802465:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802467:	83 c4 04             	add    $0x4,%esp
  80246a:	ff 75 f0             	pushl  -0x10(%ebp)
  80246d:	e8 2d ee ff ff       	call   80129f <fd2num>
  802472:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802475:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802478:	83 c4 10             	add    $0x10,%esp
  80247b:	ba 00 00 00 00       	mov    $0x0,%edx
  802480:	eb 30                	jmp    8024b2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802482:	83 ec 08             	sub    $0x8,%esp
  802485:	56                   	push   %esi
  802486:	6a 00                	push   $0x0
  802488:	e8 45 ec ff ff       	call   8010d2 <sys_page_unmap>
  80248d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802490:	83 ec 08             	sub    $0x8,%esp
  802493:	ff 75 f0             	pushl  -0x10(%ebp)
  802496:	6a 00                	push   $0x0
  802498:	e8 35 ec ff ff       	call   8010d2 <sys_page_unmap>
  80249d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024a0:	83 ec 08             	sub    $0x8,%esp
  8024a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8024a6:	6a 00                	push   $0x0
  8024a8:	e8 25 ec ff ff       	call   8010d2 <sys_page_unmap>
  8024ad:	83 c4 10             	add    $0x10,%esp
  8024b0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8024b2:	89 d0                	mov    %edx,%eax
  8024b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b7:	5b                   	pop    %ebx
  8024b8:	5e                   	pop    %esi
  8024b9:	5d                   	pop    %ebp
  8024ba:	c3                   	ret    

008024bb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024bb:	55                   	push   %ebp
  8024bc:	89 e5                	mov    %esp,%ebp
  8024be:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c4:	50                   	push   %eax
  8024c5:	ff 75 08             	pushl  0x8(%ebp)
  8024c8:	e8 48 ee ff ff       	call   801315 <fd_lookup>
  8024cd:	83 c4 10             	add    $0x10,%esp
  8024d0:	85 c0                	test   %eax,%eax
  8024d2:	78 18                	js     8024ec <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024d4:	83 ec 0c             	sub    $0xc,%esp
  8024d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8024da:	e8 d0 ed ff ff       	call   8012af <fd2data>
	return _pipeisclosed(fd, p);
  8024df:	89 c2                	mov    %eax,%edx
  8024e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e4:	e8 21 fd ff ff       	call   80220a <_pipeisclosed>
  8024e9:	83 c4 10             	add    $0x10,%esp
}
  8024ec:	c9                   	leave  
  8024ed:	c3                   	ret    

008024ee <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    

008024f8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024f8:	55                   	push   %ebp
  8024f9:	89 e5                	mov    %esp,%ebp
  8024fb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8024fe:	68 bc 30 80 00       	push   $0x8030bc
  802503:	ff 75 0c             	pushl  0xc(%ebp)
  802506:	e8 3f e7 ff ff       	call   800c4a <strcpy>
	return 0;
}
  80250b:	b8 00 00 00 00       	mov    $0x0,%eax
  802510:	c9                   	leave  
  802511:	c3                   	ret    

00802512 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802512:	55                   	push   %ebp
  802513:	89 e5                	mov    %esp,%ebp
  802515:	57                   	push   %edi
  802516:	56                   	push   %esi
  802517:	53                   	push   %ebx
  802518:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80251e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802523:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802529:	eb 2d                	jmp    802558 <devcons_write+0x46>
		m = n - tot;
  80252b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80252e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802530:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802533:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802538:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80253b:	83 ec 04             	sub    $0x4,%esp
  80253e:	53                   	push   %ebx
  80253f:	03 45 0c             	add    0xc(%ebp),%eax
  802542:	50                   	push   %eax
  802543:	57                   	push   %edi
  802544:	e8 93 e8 ff ff       	call   800ddc <memmove>
		sys_cputs(buf, m);
  802549:	83 c4 08             	add    $0x8,%esp
  80254c:	53                   	push   %ebx
  80254d:	57                   	push   %edi
  80254e:	e8 3e ea ff ff       	call   800f91 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802553:	01 de                	add    %ebx,%esi
  802555:	83 c4 10             	add    $0x10,%esp
  802558:	89 f0                	mov    %esi,%eax
  80255a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80255d:	72 cc                	jb     80252b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80255f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802562:	5b                   	pop    %ebx
  802563:	5e                   	pop    %esi
  802564:	5f                   	pop    %edi
  802565:	5d                   	pop    %ebp
  802566:	c3                   	ret    

00802567 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802567:	55                   	push   %ebp
  802568:	89 e5                	mov    %esp,%ebp
  80256a:	83 ec 08             	sub    $0x8,%esp
  80256d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802572:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802576:	74 2a                	je     8025a2 <devcons_read+0x3b>
  802578:	eb 05                	jmp    80257f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80257a:	e8 af ea ff ff       	call   80102e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80257f:	e8 2b ea ff ff       	call   800faf <sys_cgetc>
  802584:	85 c0                	test   %eax,%eax
  802586:	74 f2                	je     80257a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802588:	85 c0                	test   %eax,%eax
  80258a:	78 16                	js     8025a2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80258c:	83 f8 04             	cmp    $0x4,%eax
  80258f:	74 0c                	je     80259d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802591:	8b 55 0c             	mov    0xc(%ebp),%edx
  802594:	88 02                	mov    %al,(%edx)
	return 1;
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	eb 05                	jmp    8025a2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80259d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8025a2:	c9                   	leave  
  8025a3:	c3                   	ret    

008025a4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8025a4:	55                   	push   %ebp
  8025a5:	89 e5                	mov    %esp,%ebp
  8025a7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8025aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ad:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8025b0:	6a 01                	push   $0x1
  8025b2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025b5:	50                   	push   %eax
  8025b6:	e8 d6 e9 ff ff       	call   800f91 <sys_cputs>
}
  8025bb:	83 c4 10             	add    $0x10,%esp
  8025be:	c9                   	leave  
  8025bf:	c3                   	ret    

008025c0 <getchar>:

int
getchar(void)
{
  8025c0:	55                   	push   %ebp
  8025c1:	89 e5                	mov    %esp,%ebp
  8025c3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025c6:	6a 01                	push   $0x1
  8025c8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025cb:	50                   	push   %eax
  8025cc:	6a 00                	push   $0x0
  8025ce:	e8 a8 ef ff ff       	call   80157b <read>
	if (r < 0)
  8025d3:	83 c4 10             	add    $0x10,%esp
  8025d6:	85 c0                	test   %eax,%eax
  8025d8:	78 0f                	js     8025e9 <getchar+0x29>
		return r;
	if (r < 1)
  8025da:	85 c0                	test   %eax,%eax
  8025dc:	7e 06                	jle    8025e4 <getchar+0x24>
		return -E_EOF;
	return c;
  8025de:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025e2:	eb 05                	jmp    8025e9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025e4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025e9:	c9                   	leave  
  8025ea:	c3                   	ret    

008025eb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025eb:	55                   	push   %ebp
  8025ec:	89 e5                	mov    %esp,%ebp
  8025ee:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025f4:	50                   	push   %eax
  8025f5:	ff 75 08             	pushl  0x8(%ebp)
  8025f8:	e8 18 ed ff ff       	call   801315 <fd_lookup>
  8025fd:	83 c4 10             	add    $0x10,%esp
  802600:	85 c0                	test   %eax,%eax
  802602:	78 11                	js     802615 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802604:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802607:	8b 15 78 40 80 00    	mov    0x804078,%edx
  80260d:	39 10                	cmp    %edx,(%eax)
  80260f:	0f 94 c0             	sete   %al
  802612:	0f b6 c0             	movzbl %al,%eax
}
  802615:	c9                   	leave  
  802616:	c3                   	ret    

00802617 <opencons>:

int
opencons(void)
{
  802617:	55                   	push   %ebp
  802618:	89 e5                	mov    %esp,%ebp
  80261a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80261d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802620:	50                   	push   %eax
  802621:	e8 a0 ec ff ff       	call   8012c6 <fd_alloc>
  802626:	83 c4 10             	add    $0x10,%esp
		return r;
  802629:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80262b:	85 c0                	test   %eax,%eax
  80262d:	78 3e                	js     80266d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80262f:	83 ec 04             	sub    $0x4,%esp
  802632:	68 07 04 00 00       	push   $0x407
  802637:	ff 75 f4             	pushl  -0xc(%ebp)
  80263a:	6a 00                	push   $0x0
  80263c:	e8 0c ea ff ff       	call   80104d <sys_page_alloc>
  802641:	83 c4 10             	add    $0x10,%esp
		return r;
  802644:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802646:	85 c0                	test   %eax,%eax
  802648:	78 23                	js     80266d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80264a:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802653:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802655:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802658:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80265f:	83 ec 0c             	sub    $0xc,%esp
  802662:	50                   	push   %eax
  802663:	e8 37 ec ff ff       	call   80129f <fd2num>
  802668:	89 c2                	mov    %eax,%edx
  80266a:	83 c4 10             	add    $0x10,%esp
}
  80266d:	89 d0                	mov    %edx,%eax
  80266f:	c9                   	leave  
  802670:	c3                   	ret    

00802671 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802671:	55                   	push   %ebp
  802672:	89 e5                	mov    %esp,%ebp
  802674:	56                   	push   %esi
  802675:	53                   	push   %ebx
  802676:	8b 75 08             	mov    0x8(%ebp),%esi
  802679:	8b 45 0c             	mov    0xc(%ebp),%eax
  80267c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80267f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802681:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802686:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802689:	83 ec 0c             	sub    $0xc,%esp
  80268c:	50                   	push   %eax
  80268d:	e8 6b eb ff ff       	call   8011fd <sys_ipc_recv>

	if (from_env_store != NULL)
  802692:	83 c4 10             	add    $0x10,%esp
  802695:	85 f6                	test   %esi,%esi
  802697:	74 14                	je     8026ad <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802699:	ba 00 00 00 00       	mov    $0x0,%edx
  80269e:	85 c0                	test   %eax,%eax
  8026a0:	78 09                	js     8026ab <ipc_recv+0x3a>
  8026a2:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  8026a8:	8b 52 74             	mov    0x74(%edx),%edx
  8026ab:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8026ad:	85 db                	test   %ebx,%ebx
  8026af:	74 14                	je     8026c5 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8026b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8026b6:	85 c0                	test   %eax,%eax
  8026b8:	78 09                	js     8026c3 <ipc_recv+0x52>
  8026ba:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  8026c0:	8b 52 78             	mov    0x78(%edx),%edx
  8026c3:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8026c5:	85 c0                	test   %eax,%eax
  8026c7:	78 08                	js     8026d1 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8026c9:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8026ce:	8b 40 70             	mov    0x70(%eax),%eax
}
  8026d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5d                   	pop    %ebp
  8026d7:	c3                   	ret    

008026d8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026d8:	55                   	push   %ebp
  8026d9:	89 e5                	mov    %esp,%ebp
  8026db:	57                   	push   %edi
  8026dc:	56                   	push   %esi
  8026dd:	53                   	push   %ebx
  8026de:	83 ec 0c             	sub    $0xc,%esp
  8026e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8026ea:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8026ec:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8026f1:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8026f4:	ff 75 14             	pushl  0x14(%ebp)
  8026f7:	53                   	push   %ebx
  8026f8:	56                   	push   %esi
  8026f9:	57                   	push   %edi
  8026fa:	e8 db ea ff ff       	call   8011da <sys_ipc_try_send>

		if (err < 0) {
  8026ff:	83 c4 10             	add    $0x10,%esp
  802702:	85 c0                	test   %eax,%eax
  802704:	79 1e                	jns    802724 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802706:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802709:	75 07                	jne    802712 <ipc_send+0x3a>
				sys_yield();
  80270b:	e8 1e e9 ff ff       	call   80102e <sys_yield>
  802710:	eb e2                	jmp    8026f4 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802712:	50                   	push   %eax
  802713:	68 c8 30 80 00       	push   $0x8030c8
  802718:	6a 49                	push   $0x49
  80271a:	68 d5 30 80 00       	push   $0x8030d5
  80271f:	e8 c8 de ff ff       	call   8005ec <_panic>
		}

	} while (err < 0);

}
  802724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802727:	5b                   	pop    %ebx
  802728:	5e                   	pop    %esi
  802729:	5f                   	pop    %edi
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    

0080272c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80272c:	55                   	push   %ebp
  80272d:	89 e5                	mov    %esp,%ebp
  80272f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802732:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802737:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80273a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802740:	8b 52 50             	mov    0x50(%edx),%edx
  802743:	39 ca                	cmp    %ecx,%edx
  802745:	75 0d                	jne    802754 <ipc_find_env+0x28>
			return envs[i].env_id;
  802747:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80274a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80274f:	8b 40 48             	mov    0x48(%eax),%eax
  802752:	eb 0f                	jmp    802763 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802754:	83 c0 01             	add    $0x1,%eax
  802757:	3d 00 04 00 00       	cmp    $0x400,%eax
  80275c:	75 d9                	jne    802737 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80275e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802763:	5d                   	pop    %ebp
  802764:	c3                   	ret    

00802765 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802765:	55                   	push   %ebp
  802766:	89 e5                	mov    %esp,%ebp
  802768:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80276b:	89 d0                	mov    %edx,%eax
  80276d:	c1 e8 16             	shr    $0x16,%eax
  802770:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802777:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80277c:	f6 c1 01             	test   $0x1,%cl
  80277f:	74 1d                	je     80279e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802781:	c1 ea 0c             	shr    $0xc,%edx
  802784:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80278b:	f6 c2 01             	test   $0x1,%dl
  80278e:	74 0e                	je     80279e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802790:	c1 ea 0c             	shr    $0xc,%edx
  802793:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80279a:	ef 
  80279b:	0f b7 c0             	movzwl %ax,%eax
}
  80279e:	5d                   	pop    %ebp
  80279f:	c3                   	ret    

008027a0 <__udivdi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 f6                	test   %esi,%esi
  8027b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027bd:	89 ca                	mov    %ecx,%edx
  8027bf:	89 f8                	mov    %edi,%eax
  8027c1:	75 3d                	jne    802800 <__udivdi3+0x60>
  8027c3:	39 cf                	cmp    %ecx,%edi
  8027c5:	0f 87 c5 00 00 00    	ja     802890 <__udivdi3+0xf0>
  8027cb:	85 ff                	test   %edi,%edi
  8027cd:	89 fd                	mov    %edi,%ebp
  8027cf:	75 0b                	jne    8027dc <__udivdi3+0x3c>
  8027d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d6:	31 d2                	xor    %edx,%edx
  8027d8:	f7 f7                	div    %edi
  8027da:	89 c5                	mov    %eax,%ebp
  8027dc:	89 c8                	mov    %ecx,%eax
  8027de:	31 d2                	xor    %edx,%edx
  8027e0:	f7 f5                	div    %ebp
  8027e2:	89 c1                	mov    %eax,%ecx
  8027e4:	89 d8                	mov    %ebx,%eax
  8027e6:	89 cf                	mov    %ecx,%edi
  8027e8:	f7 f5                	div    %ebp
  8027ea:	89 c3                	mov    %eax,%ebx
  8027ec:	89 d8                	mov    %ebx,%eax
  8027ee:	89 fa                	mov    %edi,%edx
  8027f0:	83 c4 1c             	add    $0x1c,%esp
  8027f3:	5b                   	pop    %ebx
  8027f4:	5e                   	pop    %esi
  8027f5:	5f                   	pop    %edi
  8027f6:	5d                   	pop    %ebp
  8027f7:	c3                   	ret    
  8027f8:	90                   	nop
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	39 ce                	cmp    %ecx,%esi
  802802:	77 74                	ja     802878 <__udivdi3+0xd8>
  802804:	0f bd fe             	bsr    %esi,%edi
  802807:	83 f7 1f             	xor    $0x1f,%edi
  80280a:	0f 84 98 00 00 00    	je     8028a8 <__udivdi3+0x108>
  802810:	bb 20 00 00 00       	mov    $0x20,%ebx
  802815:	89 f9                	mov    %edi,%ecx
  802817:	89 c5                	mov    %eax,%ebp
  802819:	29 fb                	sub    %edi,%ebx
  80281b:	d3 e6                	shl    %cl,%esi
  80281d:	89 d9                	mov    %ebx,%ecx
  80281f:	d3 ed                	shr    %cl,%ebp
  802821:	89 f9                	mov    %edi,%ecx
  802823:	d3 e0                	shl    %cl,%eax
  802825:	09 ee                	or     %ebp,%esi
  802827:	89 d9                	mov    %ebx,%ecx
  802829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80282d:	89 d5                	mov    %edx,%ebp
  80282f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802833:	d3 ed                	shr    %cl,%ebp
  802835:	89 f9                	mov    %edi,%ecx
  802837:	d3 e2                	shl    %cl,%edx
  802839:	89 d9                	mov    %ebx,%ecx
  80283b:	d3 e8                	shr    %cl,%eax
  80283d:	09 c2                	or     %eax,%edx
  80283f:	89 d0                	mov    %edx,%eax
  802841:	89 ea                	mov    %ebp,%edx
  802843:	f7 f6                	div    %esi
  802845:	89 d5                	mov    %edx,%ebp
  802847:	89 c3                	mov    %eax,%ebx
  802849:	f7 64 24 0c          	mull   0xc(%esp)
  80284d:	39 d5                	cmp    %edx,%ebp
  80284f:	72 10                	jb     802861 <__udivdi3+0xc1>
  802851:	8b 74 24 08          	mov    0x8(%esp),%esi
  802855:	89 f9                	mov    %edi,%ecx
  802857:	d3 e6                	shl    %cl,%esi
  802859:	39 c6                	cmp    %eax,%esi
  80285b:	73 07                	jae    802864 <__udivdi3+0xc4>
  80285d:	39 d5                	cmp    %edx,%ebp
  80285f:	75 03                	jne    802864 <__udivdi3+0xc4>
  802861:	83 eb 01             	sub    $0x1,%ebx
  802864:	31 ff                	xor    %edi,%edi
  802866:	89 d8                	mov    %ebx,%eax
  802868:	89 fa                	mov    %edi,%edx
  80286a:	83 c4 1c             	add    $0x1c,%esp
  80286d:	5b                   	pop    %ebx
  80286e:	5e                   	pop    %esi
  80286f:	5f                   	pop    %edi
  802870:	5d                   	pop    %ebp
  802871:	c3                   	ret    
  802872:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802878:	31 ff                	xor    %edi,%edi
  80287a:	31 db                	xor    %ebx,%ebx
  80287c:	89 d8                	mov    %ebx,%eax
  80287e:	89 fa                	mov    %edi,%edx
  802880:	83 c4 1c             	add    $0x1c,%esp
  802883:	5b                   	pop    %ebx
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
  802888:	90                   	nop
  802889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802890:	89 d8                	mov    %ebx,%eax
  802892:	f7 f7                	div    %edi
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 c3                	mov    %eax,%ebx
  802898:	89 d8                	mov    %ebx,%eax
  80289a:	89 fa                	mov    %edi,%edx
  80289c:	83 c4 1c             	add    $0x1c,%esp
  80289f:	5b                   	pop    %ebx
  8028a0:	5e                   	pop    %esi
  8028a1:	5f                   	pop    %edi
  8028a2:	5d                   	pop    %ebp
  8028a3:	c3                   	ret    
  8028a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028a8:	39 ce                	cmp    %ecx,%esi
  8028aa:	72 0c                	jb     8028b8 <__udivdi3+0x118>
  8028ac:	31 db                	xor    %ebx,%ebx
  8028ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028b2:	0f 87 34 ff ff ff    	ja     8027ec <__udivdi3+0x4c>
  8028b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028bd:	e9 2a ff ff ff       	jmp    8027ec <__udivdi3+0x4c>
  8028c2:	66 90                	xchg   %ax,%ax
  8028c4:	66 90                	xchg   %ax,%ax
  8028c6:	66 90                	xchg   %ax,%ax
  8028c8:	66 90                	xchg   %ax,%ax
  8028ca:	66 90                	xchg   %ax,%ax
  8028cc:	66 90                	xchg   %ax,%ax
  8028ce:	66 90                	xchg   %ax,%ax

008028d0 <__umoddi3>:
  8028d0:	55                   	push   %ebp
  8028d1:	57                   	push   %edi
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	83 ec 1c             	sub    $0x1c,%esp
  8028d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8028db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8028df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8028e7:	85 d2                	test   %edx,%edx
  8028e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028f1:	89 f3                	mov    %esi,%ebx
  8028f3:	89 3c 24             	mov    %edi,(%esp)
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	75 1c                	jne    802918 <__umoddi3+0x48>
  8028fc:	39 f7                	cmp    %esi,%edi
  8028fe:	76 50                	jbe    802950 <__umoddi3+0x80>
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	f7 f7                	div    %edi
  802906:	89 d0                	mov    %edx,%eax
  802908:	31 d2                	xor    %edx,%edx
  80290a:	83 c4 1c             	add    $0x1c,%esp
  80290d:	5b                   	pop    %ebx
  80290e:	5e                   	pop    %esi
  80290f:	5f                   	pop    %edi
  802910:	5d                   	pop    %ebp
  802911:	c3                   	ret    
  802912:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802918:	39 f2                	cmp    %esi,%edx
  80291a:	89 d0                	mov    %edx,%eax
  80291c:	77 52                	ja     802970 <__umoddi3+0xa0>
  80291e:	0f bd ea             	bsr    %edx,%ebp
  802921:	83 f5 1f             	xor    $0x1f,%ebp
  802924:	75 5a                	jne    802980 <__umoddi3+0xb0>
  802926:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80292a:	0f 82 e0 00 00 00    	jb     802a10 <__umoddi3+0x140>
  802930:	39 0c 24             	cmp    %ecx,(%esp)
  802933:	0f 86 d7 00 00 00    	jbe    802a10 <__umoddi3+0x140>
  802939:	8b 44 24 08          	mov    0x8(%esp),%eax
  80293d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802941:	83 c4 1c             	add    $0x1c,%esp
  802944:	5b                   	pop    %ebx
  802945:	5e                   	pop    %esi
  802946:	5f                   	pop    %edi
  802947:	5d                   	pop    %ebp
  802948:	c3                   	ret    
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	85 ff                	test   %edi,%edi
  802952:	89 fd                	mov    %edi,%ebp
  802954:	75 0b                	jne    802961 <__umoddi3+0x91>
  802956:	b8 01 00 00 00       	mov    $0x1,%eax
  80295b:	31 d2                	xor    %edx,%edx
  80295d:	f7 f7                	div    %edi
  80295f:	89 c5                	mov    %eax,%ebp
  802961:	89 f0                	mov    %esi,%eax
  802963:	31 d2                	xor    %edx,%edx
  802965:	f7 f5                	div    %ebp
  802967:	89 c8                	mov    %ecx,%eax
  802969:	f7 f5                	div    %ebp
  80296b:	89 d0                	mov    %edx,%eax
  80296d:	eb 99                	jmp    802908 <__umoddi3+0x38>
  80296f:	90                   	nop
  802970:	89 c8                	mov    %ecx,%eax
  802972:	89 f2                	mov    %esi,%edx
  802974:	83 c4 1c             	add    $0x1c,%esp
  802977:	5b                   	pop    %ebx
  802978:	5e                   	pop    %esi
  802979:	5f                   	pop    %edi
  80297a:	5d                   	pop    %ebp
  80297b:	c3                   	ret    
  80297c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802980:	8b 34 24             	mov    (%esp),%esi
  802983:	bf 20 00 00 00       	mov    $0x20,%edi
  802988:	89 e9                	mov    %ebp,%ecx
  80298a:	29 ef                	sub    %ebp,%edi
  80298c:	d3 e0                	shl    %cl,%eax
  80298e:	89 f9                	mov    %edi,%ecx
  802990:	89 f2                	mov    %esi,%edx
  802992:	d3 ea                	shr    %cl,%edx
  802994:	89 e9                	mov    %ebp,%ecx
  802996:	09 c2                	or     %eax,%edx
  802998:	89 d8                	mov    %ebx,%eax
  80299a:	89 14 24             	mov    %edx,(%esp)
  80299d:	89 f2                	mov    %esi,%edx
  80299f:	d3 e2                	shl    %cl,%edx
  8029a1:	89 f9                	mov    %edi,%ecx
  8029a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029ab:	d3 e8                	shr    %cl,%eax
  8029ad:	89 e9                	mov    %ebp,%ecx
  8029af:	89 c6                	mov    %eax,%esi
  8029b1:	d3 e3                	shl    %cl,%ebx
  8029b3:	89 f9                	mov    %edi,%ecx
  8029b5:	89 d0                	mov    %edx,%eax
  8029b7:	d3 e8                	shr    %cl,%eax
  8029b9:	89 e9                	mov    %ebp,%ecx
  8029bb:	09 d8                	or     %ebx,%eax
  8029bd:	89 d3                	mov    %edx,%ebx
  8029bf:	89 f2                	mov    %esi,%edx
  8029c1:	f7 34 24             	divl   (%esp)
  8029c4:	89 d6                	mov    %edx,%esi
  8029c6:	d3 e3                	shl    %cl,%ebx
  8029c8:	f7 64 24 04          	mull   0x4(%esp)
  8029cc:	39 d6                	cmp    %edx,%esi
  8029ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029d2:	89 d1                	mov    %edx,%ecx
  8029d4:	89 c3                	mov    %eax,%ebx
  8029d6:	72 08                	jb     8029e0 <__umoddi3+0x110>
  8029d8:	75 11                	jne    8029eb <__umoddi3+0x11b>
  8029da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8029de:	73 0b                	jae    8029eb <__umoddi3+0x11b>
  8029e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8029e4:	1b 14 24             	sbb    (%esp),%edx
  8029e7:	89 d1                	mov    %edx,%ecx
  8029e9:	89 c3                	mov    %eax,%ebx
  8029eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8029ef:	29 da                	sub    %ebx,%edx
  8029f1:	19 ce                	sbb    %ecx,%esi
  8029f3:	89 f9                	mov    %edi,%ecx
  8029f5:	89 f0                	mov    %esi,%eax
  8029f7:	d3 e0                	shl    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	d3 ea                	shr    %cl,%edx
  8029fd:	89 e9                	mov    %ebp,%ecx
  8029ff:	d3 ee                	shr    %cl,%esi
  802a01:	09 d0                	or     %edx,%eax
  802a03:	89 f2                	mov    %esi,%edx
  802a05:	83 c4 1c             	add    $0x1c,%esp
  802a08:	5b                   	pop    %ebx
  802a09:	5e                   	pop    %esi
  802a0a:	5f                   	pop    %edi
  802a0b:	5d                   	pop    %ebp
  802a0c:	c3                   	ret    
  802a0d:	8d 76 00             	lea    0x0(%esi),%esi
  802a10:	29 f9                	sub    %edi,%ecx
  802a12:	19 d6                	sbb    %edx,%esi
  802a14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a1c:	e9 18 ff ff ff       	jmp    802939 <__umoddi3+0x69>
