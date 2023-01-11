
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
  80002c:	e8 a1 07 00 00       	call   8007d2 <libmain>
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
  80003a:	68 c0 2c 80 00       	push   $0x802cc0
  80003f:	e8 c7 08 00 00       	call   80090b <cprintf>
	exit();
  800044:	e8 cf 07 00 00       	call   800818 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec 0c 02 00 00    	sub    $0x20c,%esp
	char buf[512];
	int r;

	struct error_messages *e = errors;
  80005a:	b9 00 40 80 00       	mov    $0x804000,%ecx
	while (e->code != 0 && e->msg != 0) {
  80005f:	eb 03                	jmp    800064 <send_error+0x16>
		if (e->code == code)
			break;
		e++;
  800061:	83 c1 08             	add    $0x8,%ecx
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  800064:	8b 19                	mov    (%ecx),%ebx
  800066:	85 db                	test   %ebx,%ebx
  800068:	74 49                	je     8000b3 <send_error+0x65>
		if (e->code == code)
  80006a:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
  80006e:	74 04                	je     800074 <send_error+0x26>
  800070:	39 d3                	cmp    %edx,%ebx
  800072:	75 ed                	jne    800061 <send_error+0x13>
  800074:	89 c6                	mov    %eax,%esi
	}

	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  800076:	8b 41 04             	mov    0x4(%ecx),%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 80 2d 80 00       	push   $0x802d80
  800085:	68 00 02 00 00       	push   $0x200
  80008a:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  800090:	57                   	push   %edi
  800091:	e8 a7 0d 00 00       	call   800e3d <snprintf>
  800096:	89 c3                	mov    %eax,%ebx
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  800098:	83 c4 1c             	add    $0x1c,%esp
  80009b:	50                   	push   %eax
  80009c:	57                   	push   %edi
  80009d:	ff 36                	pushl  (%esi)
  80009f:	e8 39 18 00 00       	call   8018dd <write>
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	39 c3                	cmp    %eax,%ebx
  8000a9:	0f 95 c0             	setne  %al
  8000ac:	0f b6 c0             	movzbl %al,%eax
  8000af:	f7 d8                	neg    %eax
  8000b1:	eb 05                	jmp    8000b8 <send_error+0x6a>
			break;
		e++;
	}

	if (e->code == 0)
		return -1;
  8000b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	if (write(req->sock, buf, r) != r)
		return -1;

	return 0;
}
  8000b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	81 ec 50 03 00 00    	sub    $0x350,%esp
  8000cc:	89 c6                	mov    %eax,%esi
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000ce:	68 00 02 00 00       	push   $0x200
  8000d3:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000d9:	50                   	push   %eax
  8000da:	56                   	push   %esi
  8000db:	e8 23 17 00 00       	call   801803 <read>
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	79 17                	jns    8000fe <handle_client+0x3e>
			panic("failed to read");
  8000e7:	83 ec 04             	sub    $0x4,%esp
  8000ea:	68 c4 2c 80 00       	push   $0x802cc4
  8000ef:	68 21 01 00 00       	push   $0x121
  8000f4:	68 d3 2c 80 00       	push   $0x802cd3
  8000f9:	e8 34 07 00 00       	call   800832 <_panic>

		memset(req, 0, sizeof(*req));
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	6a 0c                	push   $0xc
  800103:	6a 00                	push   $0x0
  800105:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 c7 0e 00 00       	call   800fd5 <memset>

		req->sock = sock;
  80010e:	89 75 dc             	mov    %esi,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  800111:	83 c4 0c             	add    $0xc,%esp
  800114:	6a 04                	push   $0x4
  800116:	68 e0 2c 80 00       	push   $0x802ce0
  80011b:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800121:	50                   	push   %eax
  800122:	e8 39 0e 00 00       	call   800f60 <strncmp>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	85 c0                	test   %eax,%eax
  80012c:	0f 85 9c 02 00 00    	jne    8003ce <handle_client+0x30e>
  800132:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  800138:	eb 03                	jmp    80013d <handle_client+0x7d>
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  80013a:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  80013d:	f6 03 df             	testb  $0xdf,(%ebx)
  800140:	75 f8                	jne    80013a <handle_client+0x7a>
		request++;
	url_len = request - url;
  800142:	89 df                	mov    %ebx,%edi
  800144:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
  80014a:	29 c7                	sub    %eax,%edi

	req->url = malloc(url_len + 1);
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	8d 47 01             	lea    0x1(%edi),%eax
  800152:	50                   	push   %eax
  800153:	e8 e2 20 00 00       	call   80223a <malloc>
  800158:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  80015b:	83 c4 0c             	add    $0xc,%esp
  80015e:	57                   	push   %edi
  80015f:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  800165:	51                   	push   %ecx
  800166:	50                   	push   %eax
  800167:	e8 b6 0e 00 00       	call   801022 <memmove>
	req->url[url_len] = '\0';
  80016c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80016f:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)

	// skip space
	request++;
  800173:	83 c3 01             	add    $0x1,%ebx
  800176:	83 c4 10             	add    $0x10,%esp
  800179:	89 d8                	mov    %ebx,%eax
  80017b:	eb 03                	jmp    800180 <handle_client+0xc0>

	version = request;
	while (*request && *request != '\n')
		request++;
  80017d:	83 c0 01             	add    $0x1,%eax

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  800180:	0f b6 10             	movzbl (%eax),%edx
  800183:	84 d2                	test   %dl,%dl
  800185:	74 05                	je     80018c <handle_client+0xcc>
  800187:	80 fa 0a             	cmp    $0xa,%dl
  80018a:	75 f1                	jne    80017d <handle_client+0xbd>
		request++;
	version_len = request - version;
  80018c:	29 d8                	sub    %ebx,%eax
  80018e:	89 c7                	mov    %eax,%edi

	req->version = malloc(version_len + 1);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	8d 40 01             	lea    0x1(%eax),%eax
  800196:	50                   	push   %eax
  800197:	e8 9e 20 00 00       	call   80223a <malloc>
  80019c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  80019f:	83 c4 0c             	add    $0xc,%esp
  8001a2:	57                   	push   %edi
  8001a3:	53                   	push   %ebx
  8001a4:	50                   	push   %eax
  8001a5:	e8 78 0e 00 00       	call   801022 <memmove>
	req->version[version_len] = '\0';
  8001aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ad:	c6 04 38 00          	movb   $0x0,(%eax,%edi,1)
	// set file_size to the size of the file

	// LAB 6: Your code here.
	// panic("send_file not implemented");

	if ((fd = open(req->url, O_RDONLY)) < 0) {
  8001b1:	83 c4 08             	add    $0x8,%esp
  8001b4:	6a 00                	push   $0x0
  8001b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b9:	e8 c3 1a 00 00       	call   801c81 <open>
  8001be:	89 c7                	mov    %eax,%edi
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 12                	jns    8001d9 <handle_client+0x119>
		send_error(req, 404);
  8001c7:	ba 94 01 00 00       	mov    $0x194,%edx
  8001cc:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8001cf:	e8 7a fe ff ff       	call   80004e <send_error>
  8001d4:	e9 c9 01 00 00       	jmp    8003a2 <handle_client+0x2e2>
		goto end;
	}

	struct Stat stat;
	fstat(fd, &stat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	8d 85 c4 fc ff ff    	lea    -0x33c(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	57                   	push   %edi
  8001e4:	e8 32 18 00 00       	call   801a1b <fstat>
	if (stat.st_isdir) {
  8001e9:	83 c4 10             	add    $0x10,%esp
  8001ec:	bb 10 40 80 00       	mov    $0x804010,%ebx
  8001f1:	83 bd 48 fd ff ff 00 	cmpl   $0x0,-0x2b8(%ebp)
  8001f8:	74 15                	je     80020f <handle_client+0x14f>
		send_error(req, 404);
  8001fa:	ba 94 01 00 00       	mov    $0x194,%edx
  8001ff:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800202:	e8 47 fe ff ff       	call   80004e <send_error>
  800207:	e9 96 01 00 00       	jmp    8003a2 <handle_client+0x2e2>
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
		if (h->code == code)
			break;
		h++;
  80020c:	83 c3 08             	add    $0x8,%ebx

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
  80020f:	8b 03                	mov    (%ebx),%eax
  800211:	85 c0                	test   %eax,%eax
  800213:	0f 84 89 01 00 00    	je     8003a2 <handle_client+0x2e2>
		if (h->code == code)
  800219:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  80021d:	74 07                	je     800226 <handle_client+0x166>
  80021f:	3d c8 00 00 00       	cmp    $0xc8,%eax
  800224:	75 e6                	jne    80020c <handle_client+0x14c>
	}

	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
  800226:	83 ec 0c             	sub    $0xc,%esp
  800229:	ff 73 04             	pushl  0x4(%ebx)
  80022c:	e8 26 0c 00 00       	call   800e57 <strlen>
	if (write(req->sock, h->header, len) != len) {
  800231:	83 c4 0c             	add    $0xc,%esp
  800234:	89 85 b4 fc ff ff    	mov    %eax,-0x34c(%ebp)
  80023a:	50                   	push   %eax
  80023b:	ff 73 04             	pushl  0x4(%ebx)
  80023e:	ff 75 dc             	pushl  -0x24(%ebp)
  800241:	e8 97 16 00 00       	call   8018dd <write>
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	39 85 b4 fc ff ff    	cmp    %eax,-0x34c(%ebp)
  80024f:	0f 84 88 01 00 00    	je     8003dd <handle_client+0x31d>
		die("Failed to send bytes to client");
  800255:	b8 fc 2d 80 00       	mov    $0x802dfc,%eax
  80025a:	e8 d4 fd ff ff       	call   800033 <die>
  80025f:	e9 79 01 00 00       	jmp    8003dd <handle_client+0x31d>
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
	if (r > 63)
		panic("buffer too small!");
  800264:	83 ec 04             	sub    $0x4,%esp
  800267:	68 e5 2c 80 00       	push   $0x802ce5
  80026c:	6a 6b                	push   $0x6b
  80026e:	68 d3 2c 80 00       	push   $0x802cd3
  800273:	e8 ba 05 00 00       	call   800832 <_panic>

	if (write(req->sock, buf, r) != r)
  800278:	83 ec 04             	sub    $0x4,%esp
  80027b:	53                   	push   %ebx
  80027c:	8d 85 50 fd ff ff    	lea    -0x2b0(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	e8 52 16 00 00       	call   8018dd <write>


	if ((r = send_header(req, 200)) < 0)
		goto end;

	if ((r = send_size(req, file_size)) < 0)
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	39 c3                	cmp    %eax,%ebx
  800290:	0f 85 0c 01 00 00    	jne    8003a2 <handle_client+0x2e2>

	type = mime_type(req->url);
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  800296:	68 f7 2c 80 00       	push   $0x802cf7
  80029b:	68 01 2d 80 00       	push   $0x802d01
  8002a0:	68 80 00 00 00       	push   $0x80
  8002a5:	8d 85 50 fd ff ff    	lea    -0x2b0(%ebp),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 8c 0b 00 00       	call   800e3d <snprintf>
  8002b1:	89 c3                	mov    %eax,%ebx
	if (r > 127)
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	83 f8 7f             	cmp    $0x7f,%eax
  8002b9:	7e 17                	jle    8002d2 <handle_client+0x212>
		panic("buffer too small!");
  8002bb:	83 ec 04             	sub    $0x4,%esp
  8002be:	68 e5 2c 80 00       	push   $0x802ce5
  8002c3:	68 87 00 00 00       	push   $0x87
  8002c8:	68 d3 2c 80 00       	push   $0x802cd3
  8002cd:	e8 60 05 00 00       	call   800832 <_panic>

	if (write(req->sock, buf, r) != r)
  8002d2:	83 ec 04             	sub    $0x4,%esp
  8002d5:	50                   	push   %eax
  8002d6:	8d 85 50 fd ff ff    	lea    -0x2b0(%ebp),%eax
  8002dc:	50                   	push   %eax
  8002dd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e0:	e8 f8 15 00 00       	call   8018dd <write>
		goto end;

	if ((r = send_size(req, file_size)) < 0)
		goto end;

	if ((r = send_content_type(req)) < 0)
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	39 c3                	cmp    %eax,%ebx
  8002ea:	0f 85 b2 00 00 00    	jne    8003a2 <handle_client+0x2e2>

static int
send_header_fin(struct http_request *req)
{
	const char *fin = "\r\n";
	int fin_len = strlen(fin);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	68 45 2d 80 00       	push   $0x802d45
  8002f8:	e8 5a 0b 00 00       	call   800e57 <strlen>
  8002fd:	89 c3                	mov    %eax,%ebx

	if (write(req->sock, fin, fin_len) != fin_len)
  8002ff:	83 c4 0c             	add    $0xc,%esp
  800302:	50                   	push   %eax
  800303:	68 45 2d 80 00       	push   $0x802d45
  800308:	ff 75 dc             	pushl  -0x24(%ebp)
  80030b:	e8 cd 15 00 00       	call   8018dd <write>
		goto end;

	if ((r = send_content_type(req)) < 0)
		goto end;

	if ((r = send_header_fin(req)) < 0)
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	39 c3                	cmp    %eax,%ebx
  800315:	0f 85 87 00 00 00    	jne    8003a2 <handle_client+0x2e2>
{
	// LAB 6: Your code here.
	// panic("send_data not implemented");

	struct Stat stat;
	fstat(fd, &stat);
  80031b:	83 ec 08             	sub    $0x8,%esp
  80031e:	8d 85 50 fd ff ff    	lea    -0x2b0(%ebp),%eax
  800324:	50                   	push   %eax
  800325:	57                   	push   %edi
  800326:	e8 f0 16 00 00       	call   801a1b <fstat>
	void *buf = malloc(stat.st_size);
  80032b:	83 c4 04             	add    $0x4,%esp
  80032e:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  800334:	e8 01 1f 00 00       	call   80223a <malloc>
  800339:	89 c3                	mov    %eax,%ebx

	if (readn(fd, buf, stat.st_size) != stat.st_size) {
  80033b:	83 c4 0c             	add    $0xc,%esp
  80033e:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  800344:	50                   	push   %eax
  800345:	57                   	push   %edi
  800346:	e8 49 15 00 00       	call   801894 <readn>
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	3b 85 d0 fd ff ff    	cmp    -0x230(%ebp),%eax
  800354:	74 14                	je     80036a <handle_client+0x2aa>
		panic("Failed to read requested file");
  800356:	83 ec 04             	sub    $0x4,%esp
  800359:	68 14 2d 80 00       	push   $0x802d14
  80035e:	6a 57                	push   $0x57
  800360:	68 d3 2c 80 00       	push   $0x802cd3
  800365:	e8 c8 04 00 00       	call   800832 <_panic>
	}

  	if (write(req->sock, buf, stat.st_size) != stat.st_size) {
  80036a:	83 ec 04             	sub    $0x4,%esp
  80036d:	50                   	push   %eax
  80036e:	53                   	push   %ebx
  80036f:	ff 75 dc             	pushl  -0x24(%ebp)
  800372:	e8 66 15 00 00       	call   8018dd <write>
  800377:	83 c4 10             	add    $0x10,%esp
  80037a:	3b 85 d0 fd ff ff    	cmp    -0x230(%ebp),%eax
  800380:	74 14                	je     800396 <handle_client+0x2d6>
		panic("Failed to send bytes to client");
  800382:	83 ec 04             	sub    $0x4,%esp
  800385:	68 fc 2d 80 00       	push   $0x802dfc
  80038a:	6a 5b                	push   $0x5b
  80038c:	68 d3 2c 80 00       	push   $0x802cd3
  800391:	e8 9c 04 00 00       	call   800832 <_panic>
	}

	free(buf);
  800396:	83 ec 0c             	sub    $0xc,%esp
  800399:	53                   	push   %ebx
  80039a:	e8 ed 1d 00 00       	call   80218c <free>
  80039f:	83 c4 10             	add    $0x10,%esp
		goto end;

	r = send_data(req, fd);

end:
	close(fd);
  8003a2:	83 ec 0c             	sub    $0xc,%esp
  8003a5:	57                   	push   %edi
  8003a6:	e8 1c 13 00 00       	call   8016c7 <close>
  8003ab:	83 c4 10             	add    $0x10,%esp
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  8003ae:	83 ec 0c             	sub    $0xc,%esp
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	e8 d3 1d 00 00       	call   80218c <free>
	free(req->version);
  8003b9:	83 c4 04             	add    $0x4,%esp
  8003bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003bf:	e8 c8 1d 00 00       	call   80218c <free>

		// no keep alive
		break;
	}

	close(sock);
  8003c4:	89 34 24             	mov    %esi,(%esp)
  8003c7:	e8 fb 12 00 00       	call   8016c7 <close>
}
  8003cc:	eb 37                	jmp    800405 <handle_client+0x345>

		req->sock = sock;

		r = http_request_parse(req, buffer);
		if (r == -E_BAD_REQ)
			send_error(req, 400);
  8003ce:	ba 90 01 00 00       	mov    $0x190,%edx
  8003d3:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8003d6:	e8 73 fc ff ff       	call   80004e <send_error>
  8003db:	eb d1                	jmp    8003ae <handle_client+0x2ee>
send_size(struct http_request *req, off_t size)
{
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  8003dd:	6a ff                	push   $0xffffffff
  8003df:	68 32 2d 80 00       	push   $0x802d32
  8003e4:	6a 40                	push   $0x40
  8003e6:	8d 85 50 fd ff ff    	lea    -0x2b0(%ebp),%eax
  8003ec:	50                   	push   %eax
  8003ed:	e8 4b 0a 00 00       	call   800e3d <snprintf>
  8003f2:	89 c3                	mov    %eax,%ebx
	if (r > 63)
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	83 f8 3f             	cmp    $0x3f,%eax
  8003fa:	0f 8e 78 fe ff ff    	jle    800278 <handle_client+0x1b8>
  800400:	e9 5f fe ff ff       	jmp    800264 <handle_client+0x1a4>
		// no keep alive
		break;
	}

	close(sock);
}
  800405:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800408:	5b                   	pop    %ebx
  800409:	5e                   	pop    %esi
  80040a:	5f                   	pop    %edi
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <umain>:

void
umain(int argc, char **argv)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	57                   	push   %edi
  800411:	56                   	push   %esi
  800412:	53                   	push   %ebx
  800413:	83 ec 40             	sub    $0x40,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  800416:	c7 05 20 40 80 00 48 	movl   $0x802d48,0x804020
  80041d:	2d 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800420:	6a 06                	push   $0x6
  800422:	6a 01                	push   $0x1
  800424:	6a 02                	push   $0x2
  800426:	e8 e9 1a 00 00       	call   801f14 <socket>
  80042b:	89 c6                	mov    %eax,%esi
  80042d:	83 c4 10             	add    $0x10,%esp
  800430:	85 c0                	test   %eax,%eax
  800432:	79 0a                	jns    80043e <umain+0x31>
		die("Failed to create socket");
  800434:	b8 4f 2d 80 00       	mov    $0x802d4f,%eax
  800439:	e8 f5 fb ff ff       	call   800033 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  80043e:	83 ec 04             	sub    $0x4,%esp
  800441:	6a 10                	push   $0x10
  800443:	6a 00                	push   $0x0
  800445:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800448:	53                   	push   %ebx
  800449:	e8 87 0b 00 00       	call   800fd5 <memset>
	server.sin_family = AF_INET;			// Internet/IP
  80044e:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  800452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800459:	e8 43 01 00 00       	call   8005a1 <htonl>
  80045e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  800461:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  800468:	e8 1a 01 00 00       	call   800587 <htons>
  80046d:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  800471:	83 c4 0c             	add    $0xc,%esp
  800474:	6a 10                	push   $0x10
  800476:	53                   	push   %ebx
  800477:	56                   	push   %esi
  800478:	e8 05 1a 00 00       	call   801e82 <bind>
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	85 c0                	test   %eax,%eax
  800482:	79 0a                	jns    80048e <umain+0x81>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  800484:	b8 1c 2e 80 00       	mov    $0x802e1c,%eax
  800489:	e8 a5 fb ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	6a 05                	push   $0x5
  800493:	56                   	push   %esi
  800494:	e8 58 1a 00 00       	call   801ef1 <listen>
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	79 0a                	jns    8004aa <umain+0x9d>
		die("Failed to listen on server socket");
  8004a0:	b8 40 2e 80 00       	mov    $0x802e40,%eax
  8004a5:	e8 89 fb ff ff       	call   800033 <die>

	cprintf("Waiting for http connections...\n");
  8004aa:	83 ec 0c             	sub    $0xc,%esp
  8004ad:	68 64 2e 80 00       	push   $0x802e64
  8004b2:	e8 54 04 00 00       	call   80090b <cprintf>
  8004b7:	83 c4 10             	add    $0x10,%esp

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  8004ba:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  8004bd:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  8004c4:	83 ec 04             	sub    $0x4,%esp
  8004c7:	57                   	push   %edi
  8004c8:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8004cb:	50                   	push   %eax
  8004cc:	56                   	push   %esi
  8004cd:	e8 79 19 00 00       	call   801e4b <accept>
  8004d2:	89 c3                	mov    %eax,%ebx
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	79 0a                	jns    8004e5 <umain+0xd8>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  8004db:	b8 88 2e 80 00       	mov    $0x802e88,%eax
  8004e0:	e8 4e fb ff ff       	call   800033 <die>
		}
		handle_client(clientsock);
  8004e5:	89 d8                	mov    %ebx,%eax
  8004e7:	e8 d4 fb ff ff       	call   8000c0 <handle_client>
	}
  8004ec:	eb cf                	jmp    8004bd <umain+0xb0>

008004ee <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	57                   	push   %edi
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8004f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8004fd:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800500:	c7 45 e0 00 50 80 00 	movl   $0x805000,-0x20(%ebp)
  800507:	0f b6 0f             	movzbl (%edi),%ecx
  80050a:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80050f:	0f b6 d9             	movzbl %cl,%ebx
  800512:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800515:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800518:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80051b:	66 c1 e8 0b          	shr    $0xb,%ax
  80051f:	89 c3                	mov    %eax,%ebx
  800521:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800524:	01 c0                	add    %eax,%eax
  800526:	29 c1                	sub    %eax,%ecx
  800528:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  80052a:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80052c:	8d 72 01             	lea    0x1(%edx),%esi
  80052f:	0f b6 d2             	movzbl %dl,%edx
  800532:	83 c0 30             	add    $0x30,%eax
  800535:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800539:	89 f2                	mov    %esi,%edx
    } while(*ap);
  80053b:	84 db                	test   %bl,%bl
  80053d:	75 d0                	jne    80050f <inet_ntoa+0x21>
  80053f:	c6 07 00             	movb   $0x0,(%edi)
  800542:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800545:	eb 0d                	jmp    800554 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800547:	0f b6 c2             	movzbl %dl,%eax
  80054a:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  80054f:	88 01                	mov    %al,(%ecx)
  800551:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800554:	83 ea 01             	sub    $0x1,%edx
  800557:	80 fa ff             	cmp    $0xff,%dl
  80055a:	75 eb                	jne    800547 <inet_ntoa+0x59>
  80055c:	89 f0                	mov    %esi,%eax
  80055e:	0f b6 f0             	movzbl %al,%esi
  800561:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  800564:	8d 46 01             	lea    0x1(%esi),%eax
  800567:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056a:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  80056d:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800573:	39 c7                	cmp    %eax,%edi
  800575:	75 90                	jne    800507 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800577:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  80057a:	b8 00 50 80 00       	mov    $0x805000,%eax
  80057f:	83 c4 14             	add    $0x14,%esp
  800582:	5b                   	pop    %ebx
  800583:	5e                   	pop    %esi
  800584:	5f                   	pop    %edi
  800585:	5d                   	pop    %ebp
  800586:	c3                   	ret    

00800587 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80058a:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80058e:	66 c1 c0 08          	rol    $0x8,%ax
}
  800592:	5d                   	pop    %ebp
  800593:	c3                   	ret    

00800594 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800597:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80059b:	66 c1 c0 08          	rol    $0x8,%ax
}
  80059f:	5d                   	pop    %ebp
  8005a0:	c3                   	ret    

008005a1 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8005a1:	55                   	push   %ebp
  8005a2:	89 e5                	mov    %esp,%ebp
  8005a4:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  8005a7:	89 d1                	mov    %edx,%ecx
  8005a9:	c1 e1 18             	shl    $0x18,%ecx
  8005ac:	89 d0                	mov    %edx,%eax
  8005ae:	c1 e8 18             	shr    $0x18,%eax
  8005b1:	09 c8                	or     %ecx,%eax
  8005b3:	89 d1                	mov    %edx,%ecx
  8005b5:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8005bb:	c1 e1 08             	shl    $0x8,%ecx
  8005be:	09 c8                	or     %ecx,%eax
  8005c0:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8005c6:	c1 ea 08             	shr    $0x8,%edx
  8005c9:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8005cb:	5d                   	pop    %ebp
  8005cc:	c3                   	ret    

008005cd <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8005cd:	55                   	push   %ebp
  8005ce:	89 e5                	mov    %esp,%ebp
  8005d0:	57                   	push   %edi
  8005d1:	56                   	push   %esi
  8005d2:	53                   	push   %ebx
  8005d3:	83 ec 20             	sub    $0x20,%esp
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8005d9:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8005dc:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8005df:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8005e2:	0f b6 ca             	movzbl %dl,%ecx
  8005e5:	83 e9 30             	sub    $0x30,%ecx
  8005e8:	83 f9 09             	cmp    $0x9,%ecx
  8005eb:	0f 87 94 01 00 00    	ja     800785 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8005f1:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8005f8:	83 fa 30             	cmp    $0x30,%edx
  8005fb:	75 2b                	jne    800628 <inet_aton+0x5b>
      c = *++cp;
  8005fd:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800601:	89 d1                	mov    %edx,%ecx
  800603:	83 e1 df             	and    $0xffffffdf,%ecx
  800606:	80 f9 58             	cmp    $0x58,%cl
  800609:	74 0f                	je     80061a <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  80060b:	83 c0 01             	add    $0x1,%eax
  80060e:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800611:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800618:	eb 0e                	jmp    800628 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80061a:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80061e:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800621:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800628:	83 c0 01             	add    $0x1,%eax
  80062b:	be 00 00 00 00       	mov    $0x0,%esi
  800630:	eb 03                	jmp    800635 <inet_aton+0x68>
  800632:	83 c0 01             	add    $0x1,%eax
  800635:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800638:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80063b:	0f b6 fa             	movzbl %dl,%edi
  80063e:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800641:	83 f9 09             	cmp    $0x9,%ecx
  800644:	77 0d                	ja     800653 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800646:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  80064a:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  80064e:	0f be 10             	movsbl (%eax),%edx
  800651:	eb df                	jmp    800632 <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  800653:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800657:	75 32                	jne    80068b <inet_aton+0xbe>
  800659:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  80065c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80065f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800662:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800668:	83 e9 41             	sub    $0x41,%ecx
  80066b:	83 f9 05             	cmp    $0x5,%ecx
  80066e:	77 1b                	ja     80068b <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800670:	c1 e6 04             	shl    $0x4,%esi
  800673:	83 c2 0a             	add    $0xa,%edx
  800676:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  80067a:	19 c9                	sbb    %ecx,%ecx
  80067c:	83 e1 20             	and    $0x20,%ecx
  80067f:	83 c1 41             	add    $0x41,%ecx
  800682:	29 ca                	sub    %ecx,%edx
  800684:	09 d6                	or     %edx,%esi
        c = *++cp;
  800686:	0f be 10             	movsbl (%eax),%edx
  800689:	eb a7                	jmp    800632 <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  80068b:	83 fa 2e             	cmp    $0x2e,%edx
  80068e:	75 23                	jne    8006b3 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800690:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800693:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800696:	39 f8                	cmp    %edi,%eax
  800698:	0f 84 ee 00 00 00    	je     80078c <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  80069e:	83 c0 04             	add    $0x4,%eax
  8006a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006a4:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  8006a7:	8d 43 01             	lea    0x1(%ebx),%eax
  8006aa:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  8006ae:	e9 2f ff ff ff       	jmp    8005e2 <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006b3:	85 d2                	test   %edx,%edx
  8006b5:	74 25                	je     8006dc <inet_aton+0x10f>
  8006b7:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8006bf:	83 f9 5f             	cmp    $0x5f,%ecx
  8006c2:	0f 87 d0 00 00 00    	ja     800798 <inet_aton+0x1cb>
  8006c8:	83 fa 20             	cmp    $0x20,%edx
  8006cb:	74 0f                	je     8006dc <inet_aton+0x10f>
  8006cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006d0:	83 ea 09             	sub    $0x9,%edx
  8006d3:	83 fa 04             	cmp    $0x4,%edx
  8006d6:	0f 87 bc 00 00 00    	ja     800798 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8006dc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006df:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006e2:	29 c2                	sub    %eax,%edx
  8006e4:	c1 fa 02             	sar    $0x2,%edx
  8006e7:	83 c2 01             	add    $0x1,%edx
  8006ea:	83 fa 02             	cmp    $0x2,%edx
  8006ed:	74 20                	je     80070f <inet_aton+0x142>
  8006ef:	83 fa 02             	cmp    $0x2,%edx
  8006f2:	7f 0f                	jg     800703 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	0f 84 97 00 00 00    	je     800798 <inet_aton+0x1cb>
  800701:	eb 67                	jmp    80076a <inet_aton+0x19d>
  800703:	83 fa 03             	cmp    $0x3,%edx
  800706:	74 1e                	je     800726 <inet_aton+0x159>
  800708:	83 fa 04             	cmp    $0x4,%edx
  80070b:	74 38                	je     800745 <inet_aton+0x178>
  80070d:	eb 5b                	jmp    80076a <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800714:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  80071a:	77 7c                	ja     800798 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  80071c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80071f:	c1 e0 18             	shl    $0x18,%eax
  800722:	09 c6                	or     %eax,%esi
    break;
  800724:	eb 44                	jmp    80076a <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80072b:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800731:	77 65                	ja     800798 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800733:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800736:	c1 e2 18             	shl    $0x18,%edx
  800739:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80073c:	c1 e0 10             	shl    $0x10,%eax
  80073f:	09 d0                	or     %edx,%eax
  800741:	09 c6                	or     %eax,%esi
    break;
  800743:	eb 25                	jmp    80076a <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80074a:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800750:	77 46                	ja     800798 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800752:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800755:	c1 e2 18             	shl    $0x18,%edx
  800758:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80075b:	c1 e0 10             	shl    $0x10,%eax
  80075e:	09 c2                	or     %eax,%edx
  800760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800763:	c1 e0 08             	shl    $0x8,%eax
  800766:	09 d0                	or     %edx,%eax
  800768:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  80076a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80076e:	74 23                	je     800793 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800770:	56                   	push   %esi
  800771:	e8 2b fe ff ff       	call   8005a1 <htonl>
  800776:	83 c4 04             	add    $0x4,%esp
  800779:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077c:	89 03                	mov    %eax,(%ebx)
  return (1);
  80077e:	b8 01 00 00 00       	mov    $0x1,%eax
  800783:	eb 13                	jmp    800798 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb 0c                	jmp    800798 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80078c:	b8 00 00 00 00       	mov    $0x0,%eax
  800791:	eb 05                	jmp    800798 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800793:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800798:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5f                   	pop    %edi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8007a6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a9:	50                   	push   %eax
  8007aa:	ff 75 08             	pushl  0x8(%ebp)
  8007ad:	e8 1b fe ff ff       	call   8005cd <inet_aton>
  8007b2:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8007bc:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8007c5:	ff 75 08             	pushl  0x8(%ebp)
  8007c8:	e8 d4 fd ff ff       	call   8005a1 <htonl>
  8007cd:	83 c4 04             	add    $0x4,%esp
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007da:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8007dd:	e8 73 0a 00 00       	call   801255 <sys_getenvid>
  8007e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8007e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8007ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007ef:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007f4:	85 db                	test   %ebx,%ebx
  8007f6:	7e 07                	jle    8007ff <libmain+0x2d>
		binaryname = argv[0];
  8007f8:	8b 06                	mov    (%esi),%eax
  8007fa:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8007ff:	83 ec 08             	sub    $0x8,%esp
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	e8 04 fc ff ff       	call   80040d <umain>

	// exit gracefully
	exit();
  800809:	e8 0a 00 00 00       	call   800818 <exit>
}
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80081e:	e8 cf 0e 00 00       	call   8016f2 <close_all>
	sys_env_destroy(0);
  800823:	83 ec 0c             	sub    $0xc,%esp
  800826:	6a 00                	push   $0x0
  800828:	e8 e7 09 00 00       	call   801214 <sys_env_destroy>
}
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800837:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80083a:	8b 35 20 40 80 00    	mov    0x804020,%esi
  800840:	e8 10 0a 00 00       	call   801255 <sys_getenvid>
  800845:	83 ec 0c             	sub    $0xc,%esp
  800848:	ff 75 0c             	pushl  0xc(%ebp)
  80084b:	ff 75 08             	pushl  0x8(%ebp)
  80084e:	56                   	push   %esi
  80084f:	50                   	push   %eax
  800850:	68 dc 2e 80 00       	push   $0x802edc
  800855:	e8 b1 00 00 00       	call   80090b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80085a:	83 c4 18             	add    $0x18,%esp
  80085d:	53                   	push   %ebx
  80085e:	ff 75 10             	pushl  0x10(%ebp)
  800861:	e8 54 00 00 00       	call   8008ba <vcprintf>
	cprintf("\n");
  800866:	c7 04 24 46 2d 80 00 	movl   $0x802d46,(%esp)
  80086d:	e8 99 00 00 00       	call   80090b <cprintf>
  800872:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800875:	cc                   	int3   
  800876:	eb fd                	jmp    800875 <_panic+0x43>

00800878 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	83 ec 04             	sub    $0x4,%esp
  80087f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800882:	8b 13                	mov    (%ebx),%edx
  800884:	8d 42 01             	lea    0x1(%edx),%eax
  800887:	89 03                	mov    %eax,(%ebx)
  800889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800890:	3d ff 00 00 00       	cmp    $0xff,%eax
  800895:	75 1a                	jne    8008b1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	68 ff 00 00 00       	push   $0xff
  80089f:	8d 43 08             	lea    0x8(%ebx),%eax
  8008a2:	50                   	push   %eax
  8008a3:	e8 2f 09 00 00       	call   8011d7 <sys_cputs>
		b->idx = 0;
  8008a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8008ae:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8008b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8008b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8008c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8008ca:	00 00 00 
	b.cnt = 0;
  8008cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8008d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	ff 75 08             	pushl  0x8(%ebp)
  8008dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008e3:	50                   	push   %eax
  8008e4:	68 78 08 80 00       	push   $0x800878
  8008e9:	e8 54 01 00 00       	call   800a42 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008ee:	83 c4 08             	add    $0x8,%esp
  8008f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8008f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008fd:	50                   	push   %eax
  8008fe:	e8 d4 08 00 00       	call   8011d7 <sys_cputs>

	return b.cnt;
}
  800903:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800911:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800914:	50                   	push   %eax
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 9d ff ff ff       	call   8008ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	57                   	push   %edi
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	83 ec 1c             	sub    $0x1c,%esp
  800928:	89 c7                	mov    %eax,%edi
  80092a:	89 d6                	mov    %edx,%esi
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800932:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800935:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80093b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800940:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800943:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800946:	39 d3                	cmp    %edx,%ebx
  800948:	72 05                	jb     80094f <printnum+0x30>
  80094a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80094d:	77 45                	ja     800994 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80094f:	83 ec 0c             	sub    $0xc,%esp
  800952:	ff 75 18             	pushl  0x18(%ebp)
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80095b:	53                   	push   %ebx
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	83 ec 08             	sub    $0x8,%esp
  800962:	ff 75 e4             	pushl  -0x1c(%ebp)
  800965:	ff 75 e0             	pushl  -0x20(%ebp)
  800968:	ff 75 dc             	pushl  -0x24(%ebp)
  80096b:	ff 75 d8             	pushl  -0x28(%ebp)
  80096e:	e8 bd 20 00 00       	call   802a30 <__udivdi3>
  800973:	83 c4 18             	add    $0x18,%esp
  800976:	52                   	push   %edx
  800977:	50                   	push   %eax
  800978:	89 f2                	mov    %esi,%edx
  80097a:	89 f8                	mov    %edi,%eax
  80097c:	e8 9e ff ff ff       	call   80091f <printnum>
  800981:	83 c4 20             	add    $0x20,%esp
  800984:	eb 18                	jmp    80099e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800986:	83 ec 08             	sub    $0x8,%esp
  800989:	56                   	push   %esi
  80098a:	ff 75 18             	pushl  0x18(%ebp)
  80098d:	ff d7                	call   *%edi
  80098f:	83 c4 10             	add    $0x10,%esp
  800992:	eb 03                	jmp    800997 <printnum+0x78>
  800994:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800997:	83 eb 01             	sub    $0x1,%ebx
  80099a:	85 db                	test   %ebx,%ebx
  80099c:	7f e8                	jg     800986 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	56                   	push   %esi
  8009a2:	83 ec 04             	sub    $0x4,%esp
  8009a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8009ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8009b1:	e8 aa 21 00 00       	call   802b60 <__umoddi3>
  8009b6:	83 c4 14             	add    $0x14,%esp
  8009b9:	0f be 80 ff 2e 80 00 	movsbl 0x802eff(%eax),%eax
  8009c0:	50                   	push   %eax
  8009c1:	ff d7                	call   *%edi
}
  8009c3:	83 c4 10             	add    $0x10,%esp
  8009c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5f                   	pop    %edi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009d1:	83 fa 01             	cmp    $0x1,%edx
  8009d4:	7e 0e                	jle    8009e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009d6:	8b 10                	mov    (%eax),%edx
  8009d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009db:	89 08                	mov    %ecx,(%eax)
  8009dd:	8b 02                	mov    (%edx),%eax
  8009df:	8b 52 04             	mov    0x4(%edx),%edx
  8009e2:	eb 22                	jmp    800a06 <getuint+0x38>
	else if (lflag)
  8009e4:	85 d2                	test   %edx,%edx
  8009e6:	74 10                	je     8009f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8009e8:	8b 10                	mov    (%eax),%edx
  8009ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009ed:	89 08                	mov    %ecx,(%eax)
  8009ef:	8b 02                	mov    (%edx),%eax
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f6:	eb 0e                	jmp    800a06 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8009f8:	8b 10                	mov    (%eax),%edx
  8009fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009fd:	89 08                	mov    %ecx,(%eax)
  8009ff:	8b 02                	mov    (%edx),%eax
  800a01:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a0e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a12:	8b 10                	mov    (%eax),%edx
  800a14:	3b 50 04             	cmp    0x4(%eax),%edx
  800a17:	73 0a                	jae    800a23 <sprintputch+0x1b>
		*b->buf++ = ch;
  800a19:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a1c:	89 08                	mov    %ecx,(%eax)
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	88 02                	mov    %al,(%edx)
}
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800a2b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a2e:	50                   	push   %eax
  800a2f:	ff 75 10             	pushl  0x10(%ebp)
  800a32:	ff 75 0c             	pushl  0xc(%ebp)
  800a35:	ff 75 08             	pushl  0x8(%ebp)
  800a38:	e8 05 00 00 00       	call   800a42 <vprintfmt>
	va_end(ap);
}
  800a3d:	83 c4 10             	add    $0x10,%esp
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	83 ec 2c             	sub    $0x2c,%esp
  800a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a51:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a54:	eb 12                	jmp    800a68 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a56:	85 c0                	test   %eax,%eax
  800a58:	0f 84 89 03 00 00    	je     800de7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800a5e:	83 ec 08             	sub    $0x8,%esp
  800a61:	53                   	push   %ebx
  800a62:	50                   	push   %eax
  800a63:	ff d6                	call   *%esi
  800a65:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a68:	83 c7 01             	add    $0x1,%edi
  800a6b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a6f:	83 f8 25             	cmp    $0x25,%eax
  800a72:	75 e2                	jne    800a56 <vprintfmt+0x14>
  800a74:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800a78:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a7f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a86:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	eb 07                	jmp    800a9b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a94:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a97:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9b:	8d 47 01             	lea    0x1(%edi),%eax
  800a9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aa1:	0f b6 07             	movzbl (%edi),%eax
  800aa4:	0f b6 c8             	movzbl %al,%ecx
  800aa7:	83 e8 23             	sub    $0x23,%eax
  800aaa:	3c 55                	cmp    $0x55,%al
  800aac:	0f 87 1a 03 00 00    	ja     800dcc <vprintfmt+0x38a>
  800ab2:	0f b6 c0             	movzbl %al,%eax
  800ab5:	ff 24 85 40 30 80 00 	jmp    *0x803040(,%eax,4)
  800abc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800abf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ac3:	eb d6                	jmp    800a9b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ad0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800ad3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800ad7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800ada:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800add:	83 fa 09             	cmp    $0x9,%edx
  800ae0:	77 39                	ja     800b1b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ae2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ae5:	eb e9                	jmp    800ad0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ae7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aea:	8d 48 04             	lea    0x4(%eax),%ecx
  800aed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800af0:	8b 00                	mov    (%eax),%eax
  800af2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800af8:	eb 27                	jmp    800b21 <vprintfmt+0xdf>
  800afa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800afd:	85 c0                	test   %eax,%eax
  800aff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b04:	0f 49 c8             	cmovns %eax,%ecx
  800b07:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b0d:	eb 8c                	jmp    800a9b <vprintfmt+0x59>
  800b0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b12:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800b19:	eb 80                	jmp    800a9b <vprintfmt+0x59>
  800b1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b1e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800b21:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b25:	0f 89 70 ff ff ff    	jns    800a9b <vprintfmt+0x59>
				width = precision, precision = -1;
  800b2b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b31:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800b38:	e9 5e ff ff ff       	jmp    800a9b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b3d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b43:	e9 53 ff ff ff       	jmp    800a9b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b48:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4b:	8d 50 04             	lea    0x4(%eax),%edx
  800b4e:	89 55 14             	mov    %edx,0x14(%ebp)
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	53                   	push   %ebx
  800b55:	ff 30                	pushl  (%eax)
  800b57:	ff d6                	call   *%esi
			break;
  800b59:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b5f:	e9 04 ff ff ff       	jmp    800a68 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b64:	8b 45 14             	mov    0x14(%ebp),%eax
  800b67:	8d 50 04             	lea    0x4(%eax),%edx
  800b6a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b6d:	8b 00                	mov    (%eax),%eax
  800b6f:	99                   	cltd   
  800b70:	31 d0                	xor    %edx,%eax
  800b72:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b74:	83 f8 0f             	cmp    $0xf,%eax
  800b77:	7f 0b                	jg     800b84 <vprintfmt+0x142>
  800b79:	8b 14 85 a0 31 80 00 	mov    0x8031a0(,%eax,4),%edx
  800b80:	85 d2                	test   %edx,%edx
  800b82:	75 18                	jne    800b9c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800b84:	50                   	push   %eax
  800b85:	68 17 2f 80 00       	push   $0x802f17
  800b8a:	53                   	push   %ebx
  800b8b:	56                   	push   %esi
  800b8c:	e8 94 fe ff ff       	call   800a25 <printfmt>
  800b91:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b97:	e9 cc fe ff ff       	jmp    800a68 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800b9c:	52                   	push   %edx
  800b9d:	68 d5 32 80 00       	push   $0x8032d5
  800ba2:	53                   	push   %ebx
  800ba3:	56                   	push   %esi
  800ba4:	e8 7c fe ff ff       	call   800a25 <printfmt>
  800ba9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800baf:	e9 b4 fe ff ff       	jmp    800a68 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800bb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb7:	8d 50 04             	lea    0x4(%eax),%edx
  800bba:	89 55 14             	mov    %edx,0x14(%ebp)
  800bbd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800bbf:	85 ff                	test   %edi,%edi
  800bc1:	b8 10 2f 80 00       	mov    $0x802f10,%eax
  800bc6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800bc9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bcd:	0f 8e 94 00 00 00    	jle    800c67 <vprintfmt+0x225>
  800bd3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800bd7:	0f 84 98 00 00 00    	je     800c75 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bdd:	83 ec 08             	sub    $0x8,%esp
  800be0:	ff 75 d0             	pushl  -0x30(%ebp)
  800be3:	57                   	push   %edi
  800be4:	e8 86 02 00 00       	call   800e6f <strnlen>
  800be9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800bec:	29 c1                	sub    %eax,%ecx
  800bee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800bf1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800bf4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800bf8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bfb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800bfe:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c00:	eb 0f                	jmp    800c11 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800c02:	83 ec 08             	sub    $0x8,%esp
  800c05:	53                   	push   %ebx
  800c06:	ff 75 e0             	pushl  -0x20(%ebp)
  800c09:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c0b:	83 ef 01             	sub    $0x1,%edi
  800c0e:	83 c4 10             	add    $0x10,%esp
  800c11:	85 ff                	test   %edi,%edi
  800c13:	7f ed                	jg     800c02 <vprintfmt+0x1c0>
  800c15:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800c18:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c1b:	85 c9                	test   %ecx,%ecx
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c22:	0f 49 c1             	cmovns %ecx,%eax
  800c25:	29 c1                	sub    %eax,%ecx
  800c27:	89 75 08             	mov    %esi,0x8(%ebp)
  800c2a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c2d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c30:	89 cb                	mov    %ecx,%ebx
  800c32:	eb 4d                	jmp    800c81 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c34:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c38:	74 1b                	je     800c55 <vprintfmt+0x213>
  800c3a:	0f be c0             	movsbl %al,%eax
  800c3d:	83 e8 20             	sub    $0x20,%eax
  800c40:	83 f8 5e             	cmp    $0x5e,%eax
  800c43:	76 10                	jbe    800c55 <vprintfmt+0x213>
					putch('?', putdat);
  800c45:	83 ec 08             	sub    $0x8,%esp
  800c48:	ff 75 0c             	pushl  0xc(%ebp)
  800c4b:	6a 3f                	push   $0x3f
  800c4d:	ff 55 08             	call   *0x8(%ebp)
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	eb 0d                	jmp    800c62 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800c55:	83 ec 08             	sub    $0x8,%esp
  800c58:	ff 75 0c             	pushl  0xc(%ebp)
  800c5b:	52                   	push   %edx
  800c5c:	ff 55 08             	call   *0x8(%ebp)
  800c5f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c62:	83 eb 01             	sub    $0x1,%ebx
  800c65:	eb 1a                	jmp    800c81 <vprintfmt+0x23f>
  800c67:	89 75 08             	mov    %esi,0x8(%ebp)
  800c6a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c6d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c70:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800c73:	eb 0c                	jmp    800c81 <vprintfmt+0x23f>
  800c75:	89 75 08             	mov    %esi,0x8(%ebp)
  800c78:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c7b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c7e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800c81:	83 c7 01             	add    $0x1,%edi
  800c84:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c88:	0f be d0             	movsbl %al,%edx
  800c8b:	85 d2                	test   %edx,%edx
  800c8d:	74 23                	je     800cb2 <vprintfmt+0x270>
  800c8f:	85 f6                	test   %esi,%esi
  800c91:	78 a1                	js     800c34 <vprintfmt+0x1f2>
  800c93:	83 ee 01             	sub    $0x1,%esi
  800c96:	79 9c                	jns    800c34 <vprintfmt+0x1f2>
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca0:	eb 18                	jmp    800cba <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ca2:	83 ec 08             	sub    $0x8,%esp
  800ca5:	53                   	push   %ebx
  800ca6:	6a 20                	push   $0x20
  800ca8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800caa:	83 ef 01             	sub    $0x1,%edi
  800cad:	83 c4 10             	add    $0x10,%esp
  800cb0:	eb 08                	jmp    800cba <vprintfmt+0x278>
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	8b 75 08             	mov    0x8(%ebp),%esi
  800cb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cba:	85 ff                	test   %edi,%edi
  800cbc:	7f e4                	jg     800ca2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cbe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cc1:	e9 a2 fd ff ff       	jmp    800a68 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800cc6:	83 fa 01             	cmp    $0x1,%edx
  800cc9:	7e 16                	jle    800ce1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ccb:	8b 45 14             	mov    0x14(%ebp),%eax
  800cce:	8d 50 08             	lea    0x8(%eax),%edx
  800cd1:	89 55 14             	mov    %edx,0x14(%ebp)
  800cd4:	8b 50 04             	mov    0x4(%eax),%edx
  800cd7:	8b 00                	mov    (%eax),%eax
  800cd9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cdc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cdf:	eb 32                	jmp    800d13 <vprintfmt+0x2d1>
	else if (lflag)
  800ce1:	85 d2                	test   %edx,%edx
  800ce3:	74 18                	je     800cfd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ce5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce8:	8d 50 04             	lea    0x4(%eax),%edx
  800ceb:	89 55 14             	mov    %edx,0x14(%ebp)
  800cee:	8b 00                	mov    (%eax),%eax
  800cf0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cf3:	89 c1                	mov    %eax,%ecx
  800cf5:	c1 f9 1f             	sar    $0x1f,%ecx
  800cf8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800cfb:	eb 16                	jmp    800d13 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800cfd:	8b 45 14             	mov    0x14(%ebp),%eax
  800d00:	8d 50 04             	lea    0x4(%eax),%edx
  800d03:	89 55 14             	mov    %edx,0x14(%ebp)
  800d06:	8b 00                	mov    (%eax),%eax
  800d08:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d0b:	89 c1                	mov    %eax,%ecx
  800d0d:	c1 f9 1f             	sar    $0x1f,%ecx
  800d10:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d13:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d16:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800d19:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800d1e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d22:	79 74                	jns    800d98 <vprintfmt+0x356>
				putch('-', putdat);
  800d24:	83 ec 08             	sub    $0x8,%esp
  800d27:	53                   	push   %ebx
  800d28:	6a 2d                	push   $0x2d
  800d2a:	ff d6                	call   *%esi
				num = -(long long) num;
  800d2c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d32:	f7 d8                	neg    %eax
  800d34:	83 d2 00             	adc    $0x0,%edx
  800d37:	f7 da                	neg    %edx
  800d39:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800d3c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800d41:	eb 55                	jmp    800d98 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800d43:	8d 45 14             	lea    0x14(%ebp),%eax
  800d46:	e8 83 fc ff ff       	call   8009ce <getuint>
			base = 10;
  800d4b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800d50:	eb 46                	jmp    800d98 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800d52:	8d 45 14             	lea    0x14(%ebp),%eax
  800d55:	e8 74 fc ff ff       	call   8009ce <getuint>
			base = 8;
  800d5a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800d5f:	eb 37                	jmp    800d98 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800d61:	83 ec 08             	sub    $0x8,%esp
  800d64:	53                   	push   %ebx
  800d65:	6a 30                	push   $0x30
  800d67:	ff d6                	call   *%esi
			putch('x', putdat);
  800d69:	83 c4 08             	add    $0x8,%esp
  800d6c:	53                   	push   %ebx
  800d6d:	6a 78                	push   $0x78
  800d6f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d71:	8b 45 14             	mov    0x14(%ebp),%eax
  800d74:	8d 50 04             	lea    0x4(%eax),%edx
  800d77:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d7a:	8b 00                	mov    (%eax),%eax
  800d7c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800d81:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d84:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800d89:	eb 0d                	jmp    800d98 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d8b:	8d 45 14             	lea    0x14(%ebp),%eax
  800d8e:	e8 3b fc ff ff       	call   8009ce <getuint>
			base = 16;
  800d93:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800d9f:	57                   	push   %edi
  800da0:	ff 75 e0             	pushl  -0x20(%ebp)
  800da3:	51                   	push   %ecx
  800da4:	52                   	push   %edx
  800da5:	50                   	push   %eax
  800da6:	89 da                	mov    %ebx,%edx
  800da8:	89 f0                	mov    %esi,%eax
  800daa:	e8 70 fb ff ff       	call   80091f <printnum>
			break;
  800daf:	83 c4 20             	add    $0x20,%esp
  800db2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800db5:	e9 ae fc ff ff       	jmp    800a68 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800dba:	83 ec 08             	sub    $0x8,%esp
  800dbd:	53                   	push   %ebx
  800dbe:	51                   	push   %ecx
  800dbf:	ff d6                	call   *%esi
			break;
  800dc1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800dc7:	e9 9c fc ff ff       	jmp    800a68 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800dcc:	83 ec 08             	sub    $0x8,%esp
  800dcf:	53                   	push   %ebx
  800dd0:	6a 25                	push   $0x25
  800dd2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	eb 03                	jmp    800ddc <vprintfmt+0x39a>
  800dd9:	83 ef 01             	sub    $0x1,%edi
  800ddc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800de0:	75 f7                	jne    800dd9 <vprintfmt+0x397>
  800de2:	e9 81 fc ff ff       	jmp    800a68 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 18             	sub    $0x18,%esp
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800dfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dfe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e02:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	74 26                	je     800e36 <vsnprintf+0x47>
  800e10:	85 d2                	test   %edx,%edx
  800e12:	7e 22                	jle    800e36 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e14:	ff 75 14             	pushl  0x14(%ebp)
  800e17:	ff 75 10             	pushl  0x10(%ebp)
  800e1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e1d:	50                   	push   %eax
  800e1e:	68 08 0a 80 00       	push   $0x800a08
  800e23:	e8 1a fc ff ff       	call   800a42 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e2b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e31:	83 c4 10             	add    $0x10,%esp
  800e34:	eb 05                	jmp    800e3b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e3b:	c9                   	leave  
  800e3c:	c3                   	ret    

00800e3d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e43:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e46:	50                   	push   %eax
  800e47:	ff 75 10             	pushl  0x10(%ebp)
  800e4a:	ff 75 0c             	pushl  0xc(%ebp)
  800e4d:	ff 75 08             	pushl  0x8(%ebp)
  800e50:	e8 9a ff ff ff       	call   800def <vsnprintf>
	va_end(ap);

	return rc;
}
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    

00800e57 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	eb 03                	jmp    800e67 <strlen+0x10>
		n++;
  800e64:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e67:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e6b:	75 f7                	jne    800e64 <strlen+0xd>
		n++;
	return n;
}
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e75:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e78:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7d:	eb 03                	jmp    800e82 <strnlen+0x13>
		n++;
  800e7f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e82:	39 c2                	cmp    %eax,%edx
  800e84:	74 08                	je     800e8e <strnlen+0x1f>
  800e86:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800e8a:	75 f3                	jne    800e7f <strnlen+0x10>
  800e8c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	53                   	push   %ebx
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e9a:	89 c2                	mov    %eax,%edx
  800e9c:	83 c2 01             	add    $0x1,%edx
  800e9f:	83 c1 01             	add    $0x1,%ecx
  800ea2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ea6:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ea9:	84 db                	test   %bl,%bl
  800eab:	75 ef                	jne    800e9c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ead:	5b                   	pop    %ebx
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	53                   	push   %ebx
  800eb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800eb7:	53                   	push   %ebx
  800eb8:	e8 9a ff ff ff       	call   800e57 <strlen>
  800ebd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ec0:	ff 75 0c             	pushl  0xc(%ebp)
  800ec3:	01 d8                	add    %ebx,%eax
  800ec5:	50                   	push   %eax
  800ec6:	e8 c5 ff ff ff       	call   800e90 <strcpy>
	return dst;
}
  800ecb:	89 d8                	mov    %ebx,%eax
  800ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	8b 75 08             	mov    0x8(%ebp),%esi
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	89 f3                	mov    %esi,%ebx
  800edf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	eb 0f                	jmp    800ef5 <strncpy+0x23>
		*dst++ = *src;
  800ee6:	83 c2 01             	add    $0x1,%edx
  800ee9:	0f b6 01             	movzbl (%ecx),%eax
  800eec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800eef:	80 39 01             	cmpb   $0x1,(%ecx)
  800ef2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ef5:	39 da                	cmp    %ebx,%edx
  800ef7:	75 ed                	jne    800ee6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	8b 75 08             	mov    0x8(%ebp),%esi
  800f07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0a:	8b 55 10             	mov    0x10(%ebp),%edx
  800f0d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f0f:	85 d2                	test   %edx,%edx
  800f11:	74 21                	je     800f34 <strlcpy+0x35>
  800f13:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f17:	89 f2                	mov    %esi,%edx
  800f19:	eb 09                	jmp    800f24 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f1b:	83 c2 01             	add    $0x1,%edx
  800f1e:	83 c1 01             	add    $0x1,%ecx
  800f21:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f24:	39 c2                	cmp    %eax,%edx
  800f26:	74 09                	je     800f31 <strlcpy+0x32>
  800f28:	0f b6 19             	movzbl (%ecx),%ebx
  800f2b:	84 db                	test   %bl,%bl
  800f2d:	75 ec                	jne    800f1b <strlcpy+0x1c>
  800f2f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800f31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f34:	29 f0                	sub    %esi,%eax
}
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f43:	eb 06                	jmp    800f4b <strcmp+0x11>
		p++, q++;
  800f45:	83 c1 01             	add    $0x1,%ecx
  800f48:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f4b:	0f b6 01             	movzbl (%ecx),%eax
  800f4e:	84 c0                	test   %al,%al
  800f50:	74 04                	je     800f56 <strcmp+0x1c>
  800f52:	3a 02                	cmp    (%edx),%al
  800f54:	74 ef                	je     800f45 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f56:	0f b6 c0             	movzbl %al,%eax
  800f59:	0f b6 12             	movzbl (%edx),%edx
  800f5c:	29 d0                	sub    %edx,%eax
}
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	53                   	push   %ebx
  800f64:	8b 45 08             	mov    0x8(%ebp),%eax
  800f67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800f6f:	eb 06                	jmp    800f77 <strncmp+0x17>
		n--, p++, q++;
  800f71:	83 c0 01             	add    $0x1,%eax
  800f74:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f77:	39 d8                	cmp    %ebx,%eax
  800f79:	74 15                	je     800f90 <strncmp+0x30>
  800f7b:	0f b6 08             	movzbl (%eax),%ecx
  800f7e:	84 c9                	test   %cl,%cl
  800f80:	74 04                	je     800f86 <strncmp+0x26>
  800f82:	3a 0a                	cmp    (%edx),%cl
  800f84:	74 eb                	je     800f71 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f86:	0f b6 00             	movzbl (%eax),%eax
  800f89:	0f b6 12             	movzbl (%edx),%edx
  800f8c:	29 d0                	sub    %edx,%eax
  800f8e:	eb 05                	jmp    800f95 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f95:	5b                   	pop    %ebx
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fa2:	eb 07                	jmp    800fab <strchr+0x13>
		if (*s == c)
  800fa4:	38 ca                	cmp    %cl,%dl
  800fa6:	74 0f                	je     800fb7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800fa8:	83 c0 01             	add    $0x1,%eax
  800fab:	0f b6 10             	movzbl (%eax),%edx
  800fae:	84 d2                	test   %dl,%dl
  800fb0:	75 f2                	jne    800fa4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fc3:	eb 03                	jmp    800fc8 <strfind+0xf>
  800fc5:	83 c0 01             	add    $0x1,%eax
  800fc8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800fcb:	38 ca                	cmp    %cl,%dl
  800fcd:	74 04                	je     800fd3 <strfind+0x1a>
  800fcf:	84 d2                	test   %dl,%dl
  800fd1:	75 f2                	jne    800fc5 <strfind+0xc>
			break;
	return (char *) s;
}
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	57                   	push   %edi
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
  800fdb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fe1:	85 c9                	test   %ecx,%ecx
  800fe3:	74 36                	je     80101b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fe5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800feb:	75 28                	jne    801015 <memset+0x40>
  800fed:	f6 c1 03             	test   $0x3,%cl
  800ff0:	75 23                	jne    801015 <memset+0x40>
		c &= 0xFF;
  800ff2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ff6:	89 d3                	mov    %edx,%ebx
  800ff8:	c1 e3 08             	shl    $0x8,%ebx
  800ffb:	89 d6                	mov    %edx,%esi
  800ffd:	c1 e6 18             	shl    $0x18,%esi
  801000:	89 d0                	mov    %edx,%eax
  801002:	c1 e0 10             	shl    $0x10,%eax
  801005:	09 f0                	or     %esi,%eax
  801007:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801009:	89 d8                	mov    %ebx,%eax
  80100b:	09 d0                	or     %edx,%eax
  80100d:	c1 e9 02             	shr    $0x2,%ecx
  801010:	fc                   	cld    
  801011:	f3 ab                	rep stos %eax,%es:(%edi)
  801013:	eb 06                	jmp    80101b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801015:	8b 45 0c             	mov    0xc(%ebp),%eax
  801018:	fc                   	cld    
  801019:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80101b:	89 f8                	mov    %edi,%eax
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5f                   	pop    %edi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
  80102a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80102d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801030:	39 c6                	cmp    %eax,%esi
  801032:	73 35                	jae    801069 <memmove+0x47>
  801034:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801037:	39 d0                	cmp    %edx,%eax
  801039:	73 2e                	jae    801069 <memmove+0x47>
		s += n;
		d += n;
  80103b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80103e:	89 d6                	mov    %edx,%esi
  801040:	09 fe                	or     %edi,%esi
  801042:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801048:	75 13                	jne    80105d <memmove+0x3b>
  80104a:	f6 c1 03             	test   $0x3,%cl
  80104d:	75 0e                	jne    80105d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80104f:	83 ef 04             	sub    $0x4,%edi
  801052:	8d 72 fc             	lea    -0x4(%edx),%esi
  801055:	c1 e9 02             	shr    $0x2,%ecx
  801058:	fd                   	std    
  801059:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80105b:	eb 09                	jmp    801066 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80105d:	83 ef 01             	sub    $0x1,%edi
  801060:	8d 72 ff             	lea    -0x1(%edx),%esi
  801063:	fd                   	std    
  801064:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801066:	fc                   	cld    
  801067:	eb 1d                	jmp    801086 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801069:	89 f2                	mov    %esi,%edx
  80106b:	09 c2                	or     %eax,%edx
  80106d:	f6 c2 03             	test   $0x3,%dl
  801070:	75 0f                	jne    801081 <memmove+0x5f>
  801072:	f6 c1 03             	test   $0x3,%cl
  801075:	75 0a                	jne    801081 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801077:	c1 e9 02             	shr    $0x2,%ecx
  80107a:	89 c7                	mov    %eax,%edi
  80107c:	fc                   	cld    
  80107d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80107f:	eb 05                	jmp    801086 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801081:	89 c7                	mov    %eax,%edi
  801083:	fc                   	cld    
  801084:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80108d:	ff 75 10             	pushl  0x10(%ebp)
  801090:	ff 75 0c             	pushl  0xc(%ebp)
  801093:	ff 75 08             	pushl  0x8(%ebp)
  801096:	e8 87 ff ff ff       	call   801022 <memmove>
}
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	56                   	push   %esi
  8010a1:	53                   	push   %ebx
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a8:	89 c6                	mov    %eax,%esi
  8010aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010ad:	eb 1a                	jmp    8010c9 <memcmp+0x2c>
		if (*s1 != *s2)
  8010af:	0f b6 08             	movzbl (%eax),%ecx
  8010b2:	0f b6 1a             	movzbl (%edx),%ebx
  8010b5:	38 d9                	cmp    %bl,%cl
  8010b7:	74 0a                	je     8010c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8010b9:	0f b6 c1             	movzbl %cl,%eax
  8010bc:	0f b6 db             	movzbl %bl,%ebx
  8010bf:	29 d8                	sub    %ebx,%eax
  8010c1:	eb 0f                	jmp    8010d2 <memcmp+0x35>
		s1++, s2++;
  8010c3:	83 c0 01             	add    $0x1,%eax
  8010c6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010c9:	39 f0                	cmp    %esi,%eax
  8010cb:	75 e2                	jne    8010af <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	53                   	push   %ebx
  8010da:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8010dd:	89 c1                	mov    %eax,%ecx
  8010df:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8010e2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010e6:	eb 0a                	jmp    8010f2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010e8:	0f b6 10             	movzbl (%eax),%edx
  8010eb:	39 da                	cmp    %ebx,%edx
  8010ed:	74 07                	je     8010f6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010ef:	83 c0 01             	add    $0x1,%eax
  8010f2:	39 c8                	cmp    %ecx,%eax
  8010f4:	72 f2                	jb     8010e8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010f6:	5b                   	pop    %ebx
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801102:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801105:	eb 03                	jmp    80110a <strtol+0x11>
		s++;
  801107:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80110a:	0f b6 01             	movzbl (%ecx),%eax
  80110d:	3c 20                	cmp    $0x20,%al
  80110f:	74 f6                	je     801107 <strtol+0xe>
  801111:	3c 09                	cmp    $0x9,%al
  801113:	74 f2                	je     801107 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801115:	3c 2b                	cmp    $0x2b,%al
  801117:	75 0a                	jne    801123 <strtol+0x2a>
		s++;
  801119:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80111c:	bf 00 00 00 00       	mov    $0x0,%edi
  801121:	eb 11                	jmp    801134 <strtol+0x3b>
  801123:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801128:	3c 2d                	cmp    $0x2d,%al
  80112a:	75 08                	jne    801134 <strtol+0x3b>
		s++, neg = 1;
  80112c:	83 c1 01             	add    $0x1,%ecx
  80112f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801134:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80113a:	75 15                	jne    801151 <strtol+0x58>
  80113c:	80 39 30             	cmpb   $0x30,(%ecx)
  80113f:	75 10                	jne    801151 <strtol+0x58>
  801141:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801145:	75 7c                	jne    8011c3 <strtol+0xca>
		s += 2, base = 16;
  801147:	83 c1 02             	add    $0x2,%ecx
  80114a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80114f:	eb 16                	jmp    801167 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801151:	85 db                	test   %ebx,%ebx
  801153:	75 12                	jne    801167 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801155:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80115a:	80 39 30             	cmpb   $0x30,(%ecx)
  80115d:	75 08                	jne    801167 <strtol+0x6e>
		s++, base = 8;
  80115f:	83 c1 01             	add    $0x1,%ecx
  801162:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801167:	b8 00 00 00 00       	mov    $0x0,%eax
  80116c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80116f:	0f b6 11             	movzbl (%ecx),%edx
  801172:	8d 72 d0             	lea    -0x30(%edx),%esi
  801175:	89 f3                	mov    %esi,%ebx
  801177:	80 fb 09             	cmp    $0x9,%bl
  80117a:	77 08                	ja     801184 <strtol+0x8b>
			dig = *s - '0';
  80117c:	0f be d2             	movsbl %dl,%edx
  80117f:	83 ea 30             	sub    $0x30,%edx
  801182:	eb 22                	jmp    8011a6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801184:	8d 72 9f             	lea    -0x61(%edx),%esi
  801187:	89 f3                	mov    %esi,%ebx
  801189:	80 fb 19             	cmp    $0x19,%bl
  80118c:	77 08                	ja     801196 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80118e:	0f be d2             	movsbl %dl,%edx
  801191:	83 ea 57             	sub    $0x57,%edx
  801194:	eb 10                	jmp    8011a6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801196:	8d 72 bf             	lea    -0x41(%edx),%esi
  801199:	89 f3                	mov    %esi,%ebx
  80119b:	80 fb 19             	cmp    $0x19,%bl
  80119e:	77 16                	ja     8011b6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8011a0:	0f be d2             	movsbl %dl,%edx
  8011a3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8011a6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8011a9:	7d 0b                	jge    8011b6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8011ab:	83 c1 01             	add    $0x1,%ecx
  8011ae:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011b2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8011b4:	eb b9                	jmp    80116f <strtol+0x76>

	if (endptr)
  8011b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011ba:	74 0d                	je     8011c9 <strtol+0xd0>
		*endptr = (char *) s;
  8011bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011bf:	89 0e                	mov    %ecx,(%esi)
  8011c1:	eb 06                	jmp    8011c9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011c3:	85 db                	test   %ebx,%ebx
  8011c5:	74 98                	je     80115f <strtol+0x66>
  8011c7:	eb 9e                	jmp    801167 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	f7 da                	neg    %edx
  8011cd:	85 ff                	test   %edi,%edi
  8011cf:	0f 45 c2             	cmovne %edx,%eax
}
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	57                   	push   %edi
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e8:	89 c3                	mov    %eax,%ebx
  8011ea:	89 c7                	mov    %eax,%edi
  8011ec:	89 c6                	mov    %eax,%esi
  8011ee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	57                   	push   %edi
  8011f9:	56                   	push   %esi
  8011fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801200:	b8 01 00 00 00       	mov    $0x1,%eax
  801205:	89 d1                	mov    %edx,%ecx
  801207:	89 d3                	mov    %edx,%ebx
  801209:	89 d7                	mov    %edx,%edi
  80120b:	89 d6                	mov    %edx,%esi
  80120d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	57                   	push   %edi
  801218:	56                   	push   %esi
  801219:	53                   	push   %ebx
  80121a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801222:	b8 03 00 00 00       	mov    $0x3,%eax
  801227:	8b 55 08             	mov    0x8(%ebp),%edx
  80122a:	89 cb                	mov    %ecx,%ebx
  80122c:	89 cf                	mov    %ecx,%edi
  80122e:	89 ce                	mov    %ecx,%esi
  801230:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801232:	85 c0                	test   %eax,%eax
  801234:	7e 17                	jle    80124d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	50                   	push   %eax
  80123a:	6a 03                	push   $0x3
  80123c:	68 ff 31 80 00       	push   $0x8031ff
  801241:	6a 23                	push   $0x23
  801243:	68 1c 32 80 00       	push   $0x80321c
  801248:	e8 e5 f5 ff ff       	call   800832 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80124d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125b:	ba 00 00 00 00       	mov    $0x0,%edx
  801260:	b8 02 00 00 00       	mov    $0x2,%eax
  801265:	89 d1                	mov    %edx,%ecx
  801267:	89 d3                	mov    %edx,%ebx
  801269:	89 d7                	mov    %edx,%edi
  80126b:	89 d6                	mov    %edx,%esi
  80126d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5f                   	pop    %edi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <sys_yield>:

void
sys_yield(void)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	57                   	push   %edi
  801278:	56                   	push   %esi
  801279:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127a:	ba 00 00 00 00       	mov    $0x0,%edx
  80127f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801284:	89 d1                	mov    %edx,%ecx
  801286:	89 d3                	mov    %edx,%ebx
  801288:	89 d7                	mov    %edx,%edi
  80128a:	89 d6                	mov    %edx,%esi
  80128c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80128e:	5b                   	pop    %ebx
  80128f:	5e                   	pop    %esi
  801290:	5f                   	pop    %edi
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	57                   	push   %edi
  801297:	56                   	push   %esi
  801298:	53                   	push   %ebx
  801299:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80129c:	be 00 00 00 00       	mov    $0x0,%esi
  8012a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8012a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012af:	89 f7                	mov    %esi,%edi
  8012b1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	7e 17                	jle    8012ce <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	50                   	push   %eax
  8012bb:	6a 04                	push   $0x4
  8012bd:	68 ff 31 80 00       	push   $0x8031ff
  8012c2:	6a 23                	push   $0x23
  8012c4:	68 1c 32 80 00       	push   $0x80321c
  8012c9:	e8 64 f5 ff ff       	call   800832 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	57                   	push   %edi
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
  8012dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012df:	b8 05 00 00 00       	mov    $0x5,%eax
  8012e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ed:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012f0:	8b 75 18             	mov    0x18(%ebp),%esi
  8012f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	7e 17                	jle    801310 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012f9:	83 ec 0c             	sub    $0xc,%esp
  8012fc:	50                   	push   %eax
  8012fd:	6a 05                	push   $0x5
  8012ff:	68 ff 31 80 00       	push   $0x8031ff
  801304:	6a 23                	push   $0x23
  801306:	68 1c 32 80 00       	push   $0x80321c
  80130b:	e8 22 f5 ff ff       	call   800832 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801321:	bb 00 00 00 00       	mov    $0x0,%ebx
  801326:	b8 06 00 00 00       	mov    $0x6,%eax
  80132b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132e:	8b 55 08             	mov    0x8(%ebp),%edx
  801331:	89 df                	mov    %ebx,%edi
  801333:	89 de                	mov    %ebx,%esi
  801335:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801337:	85 c0                	test   %eax,%eax
  801339:	7e 17                	jle    801352 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	50                   	push   %eax
  80133f:	6a 06                	push   $0x6
  801341:	68 ff 31 80 00       	push   $0x8031ff
  801346:	6a 23                	push   $0x23
  801348:	68 1c 32 80 00       	push   $0x80321c
  80134d:	e8 e0 f4 ff ff       	call   800832 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801352:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801355:	5b                   	pop    %ebx
  801356:	5e                   	pop    %esi
  801357:	5f                   	pop    %edi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	57                   	push   %edi
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
  801360:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801363:	bb 00 00 00 00       	mov    $0x0,%ebx
  801368:	b8 08 00 00 00       	mov    $0x8,%eax
  80136d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801370:	8b 55 08             	mov    0x8(%ebp),%edx
  801373:	89 df                	mov    %ebx,%edi
  801375:	89 de                	mov    %ebx,%esi
  801377:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801379:	85 c0                	test   %eax,%eax
  80137b:	7e 17                	jle    801394 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	50                   	push   %eax
  801381:	6a 08                	push   $0x8
  801383:	68 ff 31 80 00       	push   $0x8031ff
  801388:	6a 23                	push   $0x23
  80138a:	68 1c 32 80 00       	push   $0x80321c
  80138f:	e8 9e f4 ff ff       	call   800832 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801394:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801397:	5b                   	pop    %ebx
  801398:	5e                   	pop    %esi
  801399:	5f                   	pop    %edi
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	57                   	push   %edi
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013aa:	b8 09 00 00 00       	mov    $0x9,%eax
  8013af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b5:	89 df                	mov    %ebx,%edi
  8013b7:	89 de                	mov    %ebx,%esi
  8013b9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	7e 17                	jle    8013d6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	50                   	push   %eax
  8013c3:	6a 09                	push   $0x9
  8013c5:	68 ff 31 80 00       	push   $0x8031ff
  8013ca:	6a 23                	push   $0x23
  8013cc:	68 1c 32 80 00       	push   $0x80321c
  8013d1:	e8 5c f4 ff ff       	call   800832 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8013f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f7:	89 df                	mov    %ebx,%edi
  8013f9:	89 de                	mov    %ebx,%esi
  8013fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	7e 17                	jle    801418 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801401:	83 ec 0c             	sub    $0xc,%esp
  801404:	50                   	push   %eax
  801405:	6a 0a                	push   $0xa
  801407:	68 ff 31 80 00       	push   $0x8031ff
  80140c:	6a 23                	push   $0x23
  80140e:	68 1c 32 80 00       	push   $0x80321c
  801413:	e8 1a f4 ff ff       	call   800832 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801418:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	57                   	push   %edi
  801424:	56                   	push   %esi
  801425:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801426:	be 00 00 00 00       	mov    $0x0,%esi
  80142b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801430:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801433:	8b 55 08             	mov    0x8(%ebp),%edx
  801436:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801439:	8b 7d 14             	mov    0x14(%ebp),%edi
  80143c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80143e:	5b                   	pop    %ebx
  80143f:	5e                   	pop    %esi
  801440:	5f                   	pop    %edi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	57                   	push   %edi
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80144c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801451:	b8 0d 00 00 00       	mov    $0xd,%eax
  801456:	8b 55 08             	mov    0x8(%ebp),%edx
  801459:	89 cb                	mov    %ecx,%ebx
  80145b:	89 cf                	mov    %ecx,%edi
  80145d:	89 ce                	mov    %ecx,%esi
  80145f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801461:	85 c0                	test   %eax,%eax
  801463:	7e 17                	jle    80147c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	50                   	push   %eax
  801469:	6a 0d                	push   $0xd
  80146b:	68 ff 31 80 00       	push   $0x8031ff
  801470:	6a 23                	push   $0x23
  801472:	68 1c 32 80 00       	push   $0x80321c
  801477:	e8 b6 f3 ff ff       	call   800832 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80147c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	57                   	push   %edi
  801488:	56                   	push   %esi
  801489:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80148a:	ba 00 00 00 00       	mov    $0x0,%edx
  80148f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801494:	89 d1                	mov    %edx,%ecx
  801496:	89 d3                	mov    %edx,%ebx
  801498:	89 d7                	mov    %edx,%edi
  80149a:	89 d6                	mov    %edx,%esi
  80149c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	57                   	push   %edi
  8014a7:	56                   	push   %esi
  8014a8:	53                   	push   %ebx
  8014a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8014b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bc:	89 df                	mov    %ebx,%edi
  8014be:	89 de                	mov    %ebx,%esi
  8014c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	7e 17                	jle    8014dd <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014c6:	83 ec 0c             	sub    $0xc,%esp
  8014c9:	50                   	push   %eax
  8014ca:	6a 0f                	push   $0xf
  8014cc:	68 ff 31 80 00       	push   $0x8031ff
  8014d1:	6a 23                	push   $0x23
  8014d3:	68 1c 32 80 00       	push   $0x80321c
  8014d8:	e8 55 f3 ff ff       	call   800832 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  8014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e0:	5b                   	pop    %ebx
  8014e1:	5e                   	pop    %esi
  8014e2:	5f                   	pop    %edi
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	57                   	push   %edi
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8014f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fe:	89 df                	mov    %ebx,%edi
  801500:	89 de                	mov    %ebx,%esi
  801502:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801504:	85 c0                	test   %eax,%eax
  801506:	7e 17                	jle    80151f <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	50                   	push   %eax
  80150c:	6a 10                	push   $0x10
  80150e:	68 ff 31 80 00       	push   $0x8031ff
  801513:	6a 23                	push   $0x23
  801515:	68 1c 32 80 00       	push   $0x80321c
  80151a:	e8 13 f3 ff ff       	call   800832 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  80151f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801522:	5b                   	pop    %ebx
  801523:	5e                   	pop    %esi
  801524:	5f                   	pop    %edi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80152a:	8b 45 08             	mov    0x8(%ebp),%eax
  80152d:	05 00 00 00 30       	add    $0x30000000,%eax
  801532:	c1 e8 0c             	shr    $0xc,%eax
}
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	05 00 00 00 30       	add    $0x30000000,%eax
  801542:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801547:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801554:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801559:	89 c2                	mov    %eax,%edx
  80155b:	c1 ea 16             	shr    $0x16,%edx
  80155e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801565:	f6 c2 01             	test   $0x1,%dl
  801568:	74 11                	je     80157b <fd_alloc+0x2d>
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	c1 ea 0c             	shr    $0xc,%edx
  80156f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	75 09                	jne    801584 <fd_alloc+0x36>
			*fd_store = fd;
  80157b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80157d:	b8 00 00 00 00       	mov    $0x0,%eax
  801582:	eb 17                	jmp    80159b <fd_alloc+0x4d>
  801584:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801589:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80158e:	75 c9                	jne    801559 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801590:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801596:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    

0080159d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015a3:	83 f8 1f             	cmp    $0x1f,%eax
  8015a6:	77 36                	ja     8015de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015a8:	c1 e0 0c             	shl    $0xc,%eax
  8015ab:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	c1 ea 16             	shr    $0x16,%edx
  8015b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015bc:	f6 c2 01             	test   $0x1,%dl
  8015bf:	74 24                	je     8015e5 <fd_lookup+0x48>
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	c1 ea 0c             	shr    $0xc,%edx
  8015c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015cd:	f6 c2 01             	test   $0x1,%dl
  8015d0:	74 1a                	je     8015ec <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d5:	89 02                	mov    %eax,(%edx)
	return 0;
  8015d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015dc:	eb 13                	jmp    8015f1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e3:	eb 0c                	jmp    8015f1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ea:	eb 05                	jmp    8015f1 <fd_lookup+0x54>
  8015ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    

008015f3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015fc:	ba a8 32 80 00       	mov    $0x8032a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801601:	eb 13                	jmp    801616 <dev_lookup+0x23>
  801603:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801606:	39 08                	cmp    %ecx,(%eax)
  801608:	75 0c                	jne    801616 <dev_lookup+0x23>
			*dev = devtab[i];
  80160a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80160f:	b8 00 00 00 00       	mov    $0x0,%eax
  801614:	eb 2e                	jmp    801644 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801616:	8b 02                	mov    (%edx),%eax
  801618:	85 c0                	test   %eax,%eax
  80161a:	75 e7                	jne    801603 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80161c:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801621:	8b 40 48             	mov    0x48(%eax),%eax
  801624:	83 ec 04             	sub    $0x4,%esp
  801627:	51                   	push   %ecx
  801628:	50                   	push   %eax
  801629:	68 2c 32 80 00       	push   $0x80322c
  80162e:	e8 d8 f2 ff ff       	call   80090b <cprintf>
	*dev = 0;
  801633:	8b 45 0c             	mov    0xc(%ebp),%eax
  801636:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
  80164b:	83 ec 10             	sub    $0x10,%esp
  80164e:	8b 75 08             	mov    0x8(%ebp),%esi
  801651:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80165e:	c1 e8 0c             	shr    $0xc,%eax
  801661:	50                   	push   %eax
  801662:	e8 36 ff ff ff       	call   80159d <fd_lookup>
  801667:	83 c4 08             	add    $0x8,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 05                	js     801673 <fd_close+0x2d>
	    || fd != fd2)
  80166e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801671:	74 0c                	je     80167f <fd_close+0x39>
		return (must_exist ? r : 0);
  801673:	84 db                	test   %bl,%bl
  801675:	ba 00 00 00 00       	mov    $0x0,%edx
  80167a:	0f 44 c2             	cmove  %edx,%eax
  80167d:	eb 41                	jmp    8016c0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	ff 36                	pushl  (%esi)
  801688:	e8 66 ff ff ff       	call   8015f3 <dev_lookup>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 1a                	js     8016b0 <fd_close+0x6a>
		if (dev->dev_close)
  801696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801699:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80169c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	74 0b                	je     8016b0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	56                   	push   %esi
  8016a9:	ff d0                	call   *%eax
  8016ab:	89 c3                	mov    %eax,%ebx
  8016ad:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	56                   	push   %esi
  8016b4:	6a 00                	push   $0x0
  8016b6:	e8 5d fc ff ff       	call   801318 <sys_page_unmap>
	return r;
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	89 d8                	mov    %ebx,%eax
}
  8016c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	ff 75 08             	pushl  0x8(%ebp)
  8016d4:	e8 c4 fe ff ff       	call   80159d <fd_lookup>
  8016d9:	83 c4 08             	add    $0x8,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 10                	js     8016f0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	6a 01                	push   $0x1
  8016e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e8:	e8 59 ff ff ff       	call   801646 <fd_close>
  8016ed:	83 c4 10             	add    $0x10,%esp
}
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <close_all>:

void
close_all(void)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	53                   	push   %ebx
  801702:	e8 c0 ff ff ff       	call   8016c7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801707:	83 c3 01             	add    $0x1,%ebx
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	83 fb 20             	cmp    $0x20,%ebx
  801710:	75 ec                	jne    8016fe <close_all+0xc>
		close(i);
}
  801712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	57                   	push   %edi
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	83 ec 2c             	sub    $0x2c,%esp
  801720:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801723:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	ff 75 08             	pushl  0x8(%ebp)
  80172a:	e8 6e fe ff ff       	call   80159d <fd_lookup>
  80172f:	83 c4 08             	add    $0x8,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	0f 88 c1 00 00 00    	js     8017fb <dup+0xe4>
		return r;
	close(newfdnum);
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	56                   	push   %esi
  80173e:	e8 84 ff ff ff       	call   8016c7 <close>

	newfd = INDEX2FD(newfdnum);
  801743:	89 f3                	mov    %esi,%ebx
  801745:	c1 e3 0c             	shl    $0xc,%ebx
  801748:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80174e:	83 c4 04             	add    $0x4,%esp
  801751:	ff 75 e4             	pushl  -0x1c(%ebp)
  801754:	e8 de fd ff ff       	call   801537 <fd2data>
  801759:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80175b:	89 1c 24             	mov    %ebx,(%esp)
  80175e:	e8 d4 fd ff ff       	call   801537 <fd2data>
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801769:	89 f8                	mov    %edi,%eax
  80176b:	c1 e8 16             	shr    $0x16,%eax
  80176e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801775:	a8 01                	test   $0x1,%al
  801777:	74 37                	je     8017b0 <dup+0x99>
  801779:	89 f8                	mov    %edi,%eax
  80177b:	c1 e8 0c             	shr    $0xc,%eax
  80177e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801785:	f6 c2 01             	test   $0x1,%dl
  801788:	74 26                	je     8017b0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80178a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801791:	83 ec 0c             	sub    $0xc,%esp
  801794:	25 07 0e 00 00       	and    $0xe07,%eax
  801799:	50                   	push   %eax
  80179a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80179d:	6a 00                	push   $0x0
  80179f:	57                   	push   %edi
  8017a0:	6a 00                	push   $0x0
  8017a2:	e8 2f fb ff ff       	call   8012d6 <sys_page_map>
  8017a7:	89 c7                	mov    %eax,%edi
  8017a9:	83 c4 20             	add    $0x20,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 2e                	js     8017de <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017b3:	89 d0                	mov    %edx,%eax
  8017b5:	c1 e8 0c             	shr    $0xc,%eax
  8017b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017bf:	83 ec 0c             	sub    $0xc,%esp
  8017c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8017c7:	50                   	push   %eax
  8017c8:	53                   	push   %ebx
  8017c9:	6a 00                	push   $0x0
  8017cb:	52                   	push   %edx
  8017cc:	6a 00                	push   $0x0
  8017ce:	e8 03 fb ff ff       	call   8012d6 <sys_page_map>
  8017d3:	89 c7                	mov    %eax,%edi
  8017d5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8017d8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017da:	85 ff                	test   %edi,%edi
  8017dc:	79 1d                	jns    8017fb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017de:	83 ec 08             	sub    $0x8,%esp
  8017e1:	53                   	push   %ebx
  8017e2:	6a 00                	push   $0x0
  8017e4:	e8 2f fb ff ff       	call   801318 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017e9:	83 c4 08             	add    $0x8,%esp
  8017ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017ef:	6a 00                	push   $0x0
  8017f1:	e8 22 fb ff ff       	call   801318 <sys_page_unmap>
	return r;
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	89 f8                	mov    %edi,%eax
}
  8017fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5f                   	pop    %edi
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	83 ec 14             	sub    $0x14,%esp
  80180a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801810:	50                   	push   %eax
  801811:	53                   	push   %ebx
  801812:	e8 86 fd ff ff       	call   80159d <fd_lookup>
  801817:	83 c4 08             	add    $0x8,%esp
  80181a:	89 c2                	mov    %eax,%edx
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 6d                	js     80188d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801826:	50                   	push   %eax
  801827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182a:	ff 30                	pushl  (%eax)
  80182c:	e8 c2 fd ff ff       	call   8015f3 <dev_lookup>
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	85 c0                	test   %eax,%eax
  801836:	78 4c                	js     801884 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801838:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80183b:	8b 42 08             	mov    0x8(%edx),%eax
  80183e:	83 e0 03             	and    $0x3,%eax
  801841:	83 f8 01             	cmp    $0x1,%eax
  801844:	75 21                	jne    801867 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801846:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80184b:	8b 40 48             	mov    0x48(%eax),%eax
  80184e:	83 ec 04             	sub    $0x4,%esp
  801851:	53                   	push   %ebx
  801852:	50                   	push   %eax
  801853:	68 6d 32 80 00       	push   $0x80326d
  801858:	e8 ae f0 ff ff       	call   80090b <cprintf>
		return -E_INVAL;
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801865:	eb 26                	jmp    80188d <read+0x8a>
	}
	if (!dev->dev_read)
  801867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186a:	8b 40 08             	mov    0x8(%eax),%eax
  80186d:	85 c0                	test   %eax,%eax
  80186f:	74 17                	je     801888 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	ff 75 10             	pushl  0x10(%ebp)
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	52                   	push   %edx
  80187b:	ff d0                	call   *%eax
  80187d:	89 c2                	mov    %eax,%edx
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	eb 09                	jmp    80188d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801884:	89 c2                	mov    %eax,%edx
  801886:	eb 05                	jmp    80188d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801888:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80188d:	89 d0                	mov    %edx,%eax
  80188f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	57                   	push   %edi
  801898:	56                   	push   %esi
  801899:	53                   	push   %ebx
  80189a:	83 ec 0c             	sub    $0xc,%esp
  80189d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018a0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018a8:	eb 21                	jmp    8018cb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018aa:	83 ec 04             	sub    $0x4,%esp
  8018ad:	89 f0                	mov    %esi,%eax
  8018af:	29 d8                	sub    %ebx,%eax
  8018b1:	50                   	push   %eax
  8018b2:	89 d8                	mov    %ebx,%eax
  8018b4:	03 45 0c             	add    0xc(%ebp),%eax
  8018b7:	50                   	push   %eax
  8018b8:	57                   	push   %edi
  8018b9:	e8 45 ff ff ff       	call   801803 <read>
		if (m < 0)
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	78 10                	js     8018d5 <readn+0x41>
			return m;
		if (m == 0)
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	74 0a                	je     8018d3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018c9:	01 c3                	add    %eax,%ebx
  8018cb:	39 f3                	cmp    %esi,%ebx
  8018cd:	72 db                	jb     8018aa <readn+0x16>
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	eb 02                	jmp    8018d5 <readn+0x41>
  8018d3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5f                   	pop    %edi
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 14             	sub    $0x14,%esp
  8018e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ea:	50                   	push   %eax
  8018eb:	53                   	push   %ebx
  8018ec:	e8 ac fc ff ff       	call   80159d <fd_lookup>
  8018f1:	83 c4 08             	add    $0x8,%esp
  8018f4:	89 c2                	mov    %eax,%edx
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 68                	js     801962 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801904:	ff 30                	pushl  (%eax)
  801906:	e8 e8 fc ff ff       	call   8015f3 <dev_lookup>
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 47                	js     801959 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801912:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801915:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801919:	75 21                	jne    80193c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80191b:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801920:	8b 40 48             	mov    0x48(%eax),%eax
  801923:	83 ec 04             	sub    $0x4,%esp
  801926:	53                   	push   %ebx
  801927:	50                   	push   %eax
  801928:	68 89 32 80 00       	push   $0x803289
  80192d:	e8 d9 ef ff ff       	call   80090b <cprintf>
		return -E_INVAL;
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80193a:	eb 26                	jmp    801962 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80193c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193f:	8b 52 0c             	mov    0xc(%edx),%edx
  801942:	85 d2                	test   %edx,%edx
  801944:	74 17                	je     80195d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801946:	83 ec 04             	sub    $0x4,%esp
  801949:	ff 75 10             	pushl  0x10(%ebp)
  80194c:	ff 75 0c             	pushl  0xc(%ebp)
  80194f:	50                   	push   %eax
  801950:	ff d2                	call   *%edx
  801952:	89 c2                	mov    %eax,%edx
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	eb 09                	jmp    801962 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801959:	89 c2                	mov    %eax,%edx
  80195b:	eb 05                	jmp    801962 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80195d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801962:	89 d0                	mov    %edx,%eax
  801964:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801967:	c9                   	leave  
  801968:	c3                   	ret    

00801969 <seek>:

int
seek(int fdnum, off_t offset)
{
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80196f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801972:	50                   	push   %eax
  801973:	ff 75 08             	pushl  0x8(%ebp)
  801976:	e8 22 fc ff ff       	call   80159d <fd_lookup>
  80197b:	83 c4 08             	add    $0x8,%esp
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 0e                	js     801990 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801982:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801985:	8b 55 0c             	mov    0xc(%ebp),%edx
  801988:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80198b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	53                   	push   %ebx
  801996:	83 ec 14             	sub    $0x14,%esp
  801999:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80199c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80199f:	50                   	push   %eax
  8019a0:	53                   	push   %ebx
  8019a1:	e8 f7 fb ff ff       	call   80159d <fd_lookup>
  8019a6:	83 c4 08             	add    $0x8,%esp
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 65                	js     801a14 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019af:	83 ec 08             	sub    $0x8,%esp
  8019b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b5:	50                   	push   %eax
  8019b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b9:	ff 30                	pushl  (%eax)
  8019bb:	e8 33 fc ff ff       	call   8015f3 <dev_lookup>
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 44                	js     801a0b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019ce:	75 21                	jne    8019f1 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019d0:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019d5:	8b 40 48             	mov    0x48(%eax),%eax
  8019d8:	83 ec 04             	sub    $0x4,%esp
  8019db:	53                   	push   %ebx
  8019dc:	50                   	push   %eax
  8019dd:	68 4c 32 80 00       	push   $0x80324c
  8019e2:	e8 24 ef ff ff       	call   80090b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019ef:	eb 23                	jmp    801a14 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8019f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f4:	8b 52 18             	mov    0x18(%edx),%edx
  8019f7:	85 d2                	test   %edx,%edx
  8019f9:	74 14                	je     801a0f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019fb:	83 ec 08             	sub    $0x8,%esp
  8019fe:	ff 75 0c             	pushl  0xc(%ebp)
  801a01:	50                   	push   %eax
  801a02:	ff d2                	call   *%edx
  801a04:	89 c2                	mov    %eax,%edx
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	eb 09                	jmp    801a14 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a0b:	89 c2                	mov    %eax,%edx
  801a0d:	eb 05                	jmp    801a14 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a0f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801a14:	89 d0                	mov    %edx,%eax
  801a16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 14             	sub    $0x14,%esp
  801a22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a25:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a28:	50                   	push   %eax
  801a29:	ff 75 08             	pushl  0x8(%ebp)
  801a2c:	e8 6c fb ff ff       	call   80159d <fd_lookup>
  801a31:	83 c4 08             	add    $0x8,%esp
  801a34:	89 c2                	mov    %eax,%edx
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 58                	js     801a92 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a3a:	83 ec 08             	sub    $0x8,%esp
  801a3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a40:	50                   	push   %eax
  801a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a44:	ff 30                	pushl  (%eax)
  801a46:	e8 a8 fb ff ff       	call   8015f3 <dev_lookup>
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	78 37                	js     801a89 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a55:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a59:	74 32                	je     801a8d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a5b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a5e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a65:	00 00 00 
	stat->st_isdir = 0;
  801a68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a6f:	00 00 00 
	stat->st_dev = dev;
  801a72:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a78:	83 ec 08             	sub    $0x8,%esp
  801a7b:	53                   	push   %ebx
  801a7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a7f:	ff 50 14             	call   *0x14(%eax)
  801a82:	89 c2                	mov    %eax,%edx
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	eb 09                	jmp    801a92 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a89:	89 c2                	mov    %eax,%edx
  801a8b:	eb 05                	jmp    801a92 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a8d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a92:	89 d0                	mov    %edx,%eax
  801a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a9e:	83 ec 08             	sub    $0x8,%esp
  801aa1:	6a 00                	push   $0x0
  801aa3:	ff 75 08             	pushl  0x8(%ebp)
  801aa6:	e8 d6 01 00 00       	call   801c81 <open>
  801aab:	89 c3                	mov    %eax,%ebx
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 1b                	js     801acf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801ab4:	83 ec 08             	sub    $0x8,%esp
  801ab7:	ff 75 0c             	pushl  0xc(%ebp)
  801aba:	50                   	push   %eax
  801abb:	e8 5b ff ff ff       	call   801a1b <fstat>
  801ac0:	89 c6                	mov    %eax,%esi
	close(fd);
  801ac2:	89 1c 24             	mov    %ebx,(%esp)
  801ac5:	e8 fd fb ff ff       	call   8016c7 <close>
	return r;
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	89 f0                	mov    %esi,%eax
}
  801acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	89 c6                	mov    %eax,%esi
  801add:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801adf:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801ae6:	75 12                	jne    801afa <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	6a 01                	push   $0x1
  801aed:	e8 c2 0e 00 00       	call   8029b4 <ipc_find_env>
  801af2:	a3 10 50 80 00       	mov    %eax,0x805010
  801af7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801afa:	6a 07                	push   $0x7
  801afc:	68 00 60 80 00       	push   $0x806000
  801b01:	56                   	push   %esi
  801b02:	ff 35 10 50 80 00    	pushl  0x805010
  801b08:	e8 53 0e 00 00       	call   802960 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b0d:	83 c4 0c             	add    $0xc,%esp
  801b10:	6a 00                	push   $0x0
  801b12:	53                   	push   %ebx
  801b13:	6a 00                	push   $0x0
  801b15:	e8 df 0d 00 00       	call   8028f9 <ipc_recv>
}
  801b1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    

00801b21 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b27:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b35:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3f:	b8 02 00 00 00       	mov    $0x2,%eax
  801b44:	e8 8d ff ff ff       	call   801ad6 <fsipc>
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	8b 40 0c             	mov    0xc(%eax),%eax
  801b57:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b61:	b8 06 00 00 00       	mov    $0x6,%eax
  801b66:	e8 6b ff ff ff       	call   801ad6 <fsipc>
}
  801b6b:	c9                   	leave  
  801b6c:	c3                   	ret    

00801b6d <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	53                   	push   %ebx
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b77:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b82:	ba 00 00 00 00       	mov    $0x0,%edx
  801b87:	b8 05 00 00 00       	mov    $0x5,%eax
  801b8c:	e8 45 ff ff ff       	call   801ad6 <fsipc>
  801b91:	85 c0                	test   %eax,%eax
  801b93:	78 2c                	js     801bc1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b95:	83 ec 08             	sub    $0x8,%esp
  801b98:	68 00 60 80 00       	push   $0x806000
  801b9d:	53                   	push   %ebx
  801b9e:	e8 ed f2 ff ff       	call   800e90 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ba3:	a1 80 60 80 00       	mov    0x806080,%eax
  801ba8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bae:	a1 84 60 80 00       	mov    0x806084,%eax
  801bb3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  801bd2:	8b 52 0c             	mov    0xc(%edx),%edx
  801bd5:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bdb:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801be0:	50                   	push   %eax
  801be1:	ff 75 0c             	pushl  0xc(%ebp)
  801be4:	68 08 60 80 00       	push   $0x806008
  801be9:	e8 34 f4 ff ff       	call   801022 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801bee:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf3:	b8 04 00 00 00       	mov    $0x4,%eax
  801bf8:	e8 d9 fe ff ff       	call   801ad6 <fsipc>

}
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c07:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c0d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c12:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c18:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1d:	b8 03 00 00 00       	mov    $0x3,%eax
  801c22:	e8 af fe ff ff       	call   801ad6 <fsipc>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 4b                	js     801c78 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c2d:	39 c6                	cmp    %eax,%esi
  801c2f:	73 16                	jae    801c47 <devfile_read+0x48>
  801c31:	68 bc 32 80 00       	push   $0x8032bc
  801c36:	68 c3 32 80 00       	push   $0x8032c3
  801c3b:	6a 7c                	push   $0x7c
  801c3d:	68 d8 32 80 00       	push   $0x8032d8
  801c42:	e8 eb eb ff ff       	call   800832 <_panic>
	assert(r <= PGSIZE);
  801c47:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c4c:	7e 16                	jle    801c64 <devfile_read+0x65>
  801c4e:	68 e3 32 80 00       	push   $0x8032e3
  801c53:	68 c3 32 80 00       	push   $0x8032c3
  801c58:	6a 7d                	push   $0x7d
  801c5a:	68 d8 32 80 00       	push   $0x8032d8
  801c5f:	e8 ce eb ff ff       	call   800832 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c64:	83 ec 04             	sub    $0x4,%esp
  801c67:	50                   	push   %eax
  801c68:	68 00 60 80 00       	push   $0x806000
  801c6d:	ff 75 0c             	pushl  0xc(%ebp)
  801c70:	e8 ad f3 ff ff       	call   801022 <memmove>
	return r;
  801c75:	83 c4 10             	add    $0x10,%esp
}
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    

00801c81 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	53                   	push   %ebx
  801c85:	83 ec 20             	sub    $0x20,%esp
  801c88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c8b:	53                   	push   %ebx
  801c8c:	e8 c6 f1 ff ff       	call   800e57 <strlen>
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c99:	7f 67                	jg     801d02 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c9b:	83 ec 0c             	sub    $0xc,%esp
  801c9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca1:	50                   	push   %eax
  801ca2:	e8 a7 f8 ff ff       	call   80154e <fd_alloc>
  801ca7:	83 c4 10             	add    $0x10,%esp
		return r;
  801caa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	78 57                	js     801d07 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	53                   	push   %ebx
  801cb4:	68 00 60 80 00       	push   $0x806000
  801cb9:	e8 d2 f1 ff ff       	call   800e90 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc1:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cce:	e8 03 fe ff ff       	call   801ad6 <fsipc>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	79 14                	jns    801cf0 <open+0x6f>
		fd_close(fd, 0);
  801cdc:	83 ec 08             	sub    $0x8,%esp
  801cdf:	6a 00                	push   $0x0
  801ce1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce4:	e8 5d f9 ff ff       	call   801646 <fd_close>
		return r;
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	89 da                	mov    %ebx,%edx
  801cee:	eb 17                	jmp    801d07 <open+0x86>
	}

	return fd2num(fd);
  801cf0:	83 ec 0c             	sub    $0xc,%esp
  801cf3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf6:	e8 2c f8 ff ff       	call   801527 <fd2num>
  801cfb:	89 c2                	mov    %eax,%edx
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	eb 05                	jmp    801d07 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d02:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d07:	89 d0                	mov    %edx,%eax
  801d09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d14:	ba 00 00 00 00       	mov    $0x0,%edx
  801d19:	b8 08 00 00 00       	mov    $0x8,%eax
  801d1e:	e8 b3 fd ff ff       	call   801ad6 <fsipc>
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    

00801d25 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d2b:	68 ef 32 80 00       	push   $0x8032ef
  801d30:	ff 75 0c             	pushl  0xc(%ebp)
  801d33:	e8 58 f1 ff ff       	call   800e90 <strcpy>
	return 0;
}
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	53                   	push   %ebx
  801d43:	83 ec 10             	sub    $0x10,%esp
  801d46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d49:	53                   	push   %ebx
  801d4a:	e8 9e 0c 00 00       	call   8029ed <pageref>
  801d4f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d52:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d57:	83 f8 01             	cmp    $0x1,%eax
  801d5a:	75 10                	jne    801d6c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d5c:	83 ec 0c             	sub    $0xc,%esp
  801d5f:	ff 73 0c             	pushl  0xc(%ebx)
  801d62:	e8 c0 02 00 00       	call   802027 <nsipc_close>
  801d67:	89 c2                	mov    %eax,%edx
  801d69:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d6c:	89 d0                	mov    %edx,%eax
  801d6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d79:	6a 00                	push   $0x0
  801d7b:	ff 75 10             	pushl  0x10(%ebp)
  801d7e:	ff 75 0c             	pushl  0xc(%ebp)
  801d81:	8b 45 08             	mov    0x8(%ebp),%eax
  801d84:	ff 70 0c             	pushl  0xc(%eax)
  801d87:	e8 78 03 00 00       	call   802104 <nsipc_send>
}
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d94:	6a 00                	push   $0x0
  801d96:	ff 75 10             	pushl  0x10(%ebp)
  801d99:	ff 75 0c             	pushl  0xc(%ebp)
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	ff 70 0c             	pushl  0xc(%eax)
  801da2:	e8 f1 02 00 00       	call   802098 <nsipc_recv>
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801daf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801db2:	52                   	push   %edx
  801db3:	50                   	push   %eax
  801db4:	e8 e4 f7 ff ff       	call   80159d <fd_lookup>
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 17                	js     801dd7 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc3:	8b 0d 40 40 80 00    	mov    0x804040,%ecx
  801dc9:	39 08                	cmp    %ecx,(%eax)
  801dcb:	75 05                	jne    801dd2 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801dcd:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd0:	eb 05                	jmp    801dd7 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801dd2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    

00801dd9 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 1c             	sub    $0x1c,%esp
  801de1:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801de3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de6:	50                   	push   %eax
  801de7:	e8 62 f7 ff ff       	call   80154e <fd_alloc>
  801dec:	89 c3                	mov    %eax,%ebx
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 1b                	js     801e10 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	68 07 04 00 00       	push   $0x407
  801dfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801e00:	6a 00                	push   $0x0
  801e02:	e8 8c f4 ff ff       	call   801293 <sys_page_alloc>
  801e07:	89 c3                	mov    %eax,%ebx
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	79 10                	jns    801e20 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801e10:	83 ec 0c             	sub    $0xc,%esp
  801e13:	56                   	push   %esi
  801e14:	e8 0e 02 00 00       	call   802027 <nsipc_close>
		return r;
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	89 d8                	mov    %ebx,%eax
  801e1e:	eb 24                	jmp    801e44 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e20:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e29:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e35:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	50                   	push   %eax
  801e3c:	e8 e6 f6 ff ff       	call   801527 <fd2num>
  801e41:	83 c4 10             	add    $0x10,%esp
}
  801e44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e51:	8b 45 08             	mov    0x8(%ebp),%eax
  801e54:	e8 50 ff ff ff       	call   801da9 <fd2sockid>
		return r;
  801e59:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 1f                	js     801e7e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	ff 75 10             	pushl  0x10(%ebp)
  801e65:	ff 75 0c             	pushl  0xc(%ebp)
  801e68:	50                   	push   %eax
  801e69:	e8 12 01 00 00       	call   801f80 <nsipc_accept>
  801e6e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e71:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 07                	js     801e7e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e77:	e8 5d ff ff ff       	call   801dd9 <alloc_sockfd>
  801e7c:	89 c1                	mov    %eax,%ecx
}
  801e7e:	89 c8                	mov    %ecx,%eax
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    

00801e82 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e88:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8b:	e8 19 ff ff ff       	call   801da9 <fd2sockid>
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 12                	js     801ea6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e94:	83 ec 04             	sub    $0x4,%esp
  801e97:	ff 75 10             	pushl  0x10(%ebp)
  801e9a:	ff 75 0c             	pushl  0xc(%ebp)
  801e9d:	50                   	push   %eax
  801e9e:	e8 2d 01 00 00       	call   801fd0 <nsipc_bind>
  801ea3:	83 c4 10             	add    $0x10,%esp
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <shutdown>:

int
shutdown(int s, int how)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eae:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb1:	e8 f3 fe ff ff       	call   801da9 <fd2sockid>
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 0f                	js     801ec9 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801eba:	83 ec 08             	sub    $0x8,%esp
  801ebd:	ff 75 0c             	pushl  0xc(%ebp)
  801ec0:	50                   	push   %eax
  801ec1:	e8 3f 01 00 00       	call   802005 <nsipc_shutdown>
  801ec6:	83 c4 10             	add    $0x10,%esp
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	e8 d0 fe ff ff       	call   801da9 <fd2sockid>
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 12                	js     801eef <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801edd:	83 ec 04             	sub    $0x4,%esp
  801ee0:	ff 75 10             	pushl  0x10(%ebp)
  801ee3:	ff 75 0c             	pushl  0xc(%ebp)
  801ee6:	50                   	push   %eax
  801ee7:	e8 55 01 00 00       	call   802041 <nsipc_connect>
  801eec:	83 c4 10             	add    $0x10,%esp
}
  801eef:	c9                   	leave  
  801ef0:	c3                   	ret    

00801ef1 <listen>:

int
listen(int s, int backlog)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  801efa:	e8 aa fe ff ff       	call   801da9 <fd2sockid>
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 0f                	js     801f12 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f03:	83 ec 08             	sub    $0x8,%esp
  801f06:	ff 75 0c             	pushl  0xc(%ebp)
  801f09:	50                   	push   %eax
  801f0a:	e8 67 01 00 00       	call   802076 <nsipc_listen>
  801f0f:	83 c4 10             	add    $0x10,%esp
}
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    

00801f14 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f1a:	ff 75 10             	pushl  0x10(%ebp)
  801f1d:	ff 75 0c             	pushl  0xc(%ebp)
  801f20:	ff 75 08             	pushl  0x8(%ebp)
  801f23:	e8 3a 02 00 00       	call   802162 <nsipc_socket>
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	78 05                	js     801f34 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f2f:	e8 a5 fe ff ff       	call   801dd9 <alloc_sockfd>
}
  801f34:	c9                   	leave  
  801f35:	c3                   	ret    

00801f36 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	53                   	push   %ebx
  801f3a:	83 ec 04             	sub    $0x4,%esp
  801f3d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f3f:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  801f46:	75 12                	jne    801f5a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f48:	83 ec 0c             	sub    $0xc,%esp
  801f4b:	6a 02                	push   $0x2
  801f4d:	e8 62 0a 00 00       	call   8029b4 <ipc_find_env>
  801f52:	a3 14 50 80 00       	mov    %eax,0x805014
  801f57:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f5a:	6a 07                	push   $0x7
  801f5c:	68 00 70 80 00       	push   $0x807000
  801f61:	53                   	push   %ebx
  801f62:	ff 35 14 50 80 00    	pushl  0x805014
  801f68:	e8 f3 09 00 00       	call   802960 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f6d:	83 c4 0c             	add    $0xc,%esp
  801f70:	6a 00                	push   $0x0
  801f72:	6a 00                	push   $0x0
  801f74:	6a 00                	push   $0x0
  801f76:	e8 7e 09 00 00       	call   8028f9 <ipc_recv>
}
  801f7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7e:	c9                   	leave  
  801f7f:	c3                   	ret    

00801f80 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	56                   	push   %esi
  801f84:	53                   	push   %ebx
  801f85:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f88:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f90:	8b 06                	mov    (%esi),%eax
  801f92:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f97:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9c:	e8 95 ff ff ff       	call   801f36 <nsipc>
  801fa1:	89 c3                	mov    %eax,%ebx
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	78 20                	js     801fc7 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fa7:	83 ec 04             	sub    $0x4,%esp
  801faa:	ff 35 10 70 80 00    	pushl  0x807010
  801fb0:	68 00 70 80 00       	push   $0x807000
  801fb5:	ff 75 0c             	pushl  0xc(%ebp)
  801fb8:	e8 65 f0 ff ff       	call   801022 <memmove>
		*addrlen = ret->ret_addrlen;
  801fbd:	a1 10 70 80 00       	mov    0x807010,%eax
  801fc2:	89 06                	mov    %eax,(%esi)
  801fc4:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801fc7:	89 d8                	mov    %ebx,%eax
  801fc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fcc:	5b                   	pop    %ebx
  801fcd:	5e                   	pop    %esi
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    

00801fd0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 08             	sub    $0x8,%esp
  801fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fda:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fe2:	53                   	push   %ebx
  801fe3:	ff 75 0c             	pushl  0xc(%ebp)
  801fe6:	68 04 70 80 00       	push   $0x807004
  801feb:	e8 32 f0 ff ff       	call   801022 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ff0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801ff6:	b8 02 00 00 00       	mov    $0x2,%eax
  801ffb:	e8 36 ff ff ff       	call   801f36 <nsipc>
}
  802000:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802003:	c9                   	leave  
  802004:	c3                   	ret    

00802005 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80200b:	8b 45 08             	mov    0x8(%ebp),%eax
  80200e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802013:	8b 45 0c             	mov    0xc(%ebp),%eax
  802016:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80201b:	b8 03 00 00 00       	mov    $0x3,%eax
  802020:	e8 11 ff ff ff       	call   801f36 <nsipc>
}
  802025:	c9                   	leave  
  802026:	c3                   	ret    

00802027 <nsipc_close>:

int
nsipc_close(int s)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80202d:	8b 45 08             	mov    0x8(%ebp),%eax
  802030:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802035:	b8 04 00 00 00       	mov    $0x4,%eax
  80203a:	e8 f7 fe ff ff       	call   801f36 <nsipc>
}
  80203f:	c9                   	leave  
  802040:	c3                   	ret    

00802041 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	53                   	push   %ebx
  802045:	83 ec 08             	sub    $0x8,%esp
  802048:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802053:	53                   	push   %ebx
  802054:	ff 75 0c             	pushl  0xc(%ebp)
  802057:	68 04 70 80 00       	push   $0x807004
  80205c:	e8 c1 ef ff ff       	call   801022 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802061:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802067:	b8 05 00 00 00       	mov    $0x5,%eax
  80206c:	e8 c5 fe ff ff       	call   801f36 <nsipc>
}
  802071:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802074:	c9                   	leave  
  802075:	c3                   	ret    

00802076 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80207c:	8b 45 08             	mov    0x8(%ebp),%eax
  80207f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802084:	8b 45 0c             	mov    0xc(%ebp),%eax
  802087:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80208c:	b8 06 00 00 00       	mov    $0x6,%eax
  802091:	e8 a0 fe ff ff       	call   801f36 <nsipc>
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	56                   	push   %esi
  80209c:	53                   	push   %ebx
  80209d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8020a8:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8020ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8020b1:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020b6:	b8 07 00 00 00       	mov    $0x7,%eax
  8020bb:	e8 76 fe ff ff       	call   801f36 <nsipc>
  8020c0:	89 c3                	mov    %eax,%ebx
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	78 35                	js     8020fb <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8020c6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020cb:	7f 04                	jg     8020d1 <nsipc_recv+0x39>
  8020cd:	39 c6                	cmp    %eax,%esi
  8020cf:	7d 16                	jge    8020e7 <nsipc_recv+0x4f>
  8020d1:	68 fb 32 80 00       	push   $0x8032fb
  8020d6:	68 c3 32 80 00       	push   $0x8032c3
  8020db:	6a 62                	push   $0x62
  8020dd:	68 10 33 80 00       	push   $0x803310
  8020e2:	e8 4b e7 ff ff       	call   800832 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020e7:	83 ec 04             	sub    $0x4,%esp
  8020ea:	50                   	push   %eax
  8020eb:	68 00 70 80 00       	push   $0x807000
  8020f0:	ff 75 0c             	pushl  0xc(%ebp)
  8020f3:	e8 2a ef ff ff       	call   801022 <memmove>
  8020f8:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020fb:	89 d8                	mov    %ebx,%eax
  8020fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    

00802104 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	53                   	push   %ebx
  802108:	83 ec 04             	sub    $0x4,%esp
  80210b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
  802111:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802116:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80211c:	7e 16                	jle    802134 <nsipc_send+0x30>
  80211e:	68 1c 33 80 00       	push   $0x80331c
  802123:	68 c3 32 80 00       	push   $0x8032c3
  802128:	6a 6d                	push   $0x6d
  80212a:	68 10 33 80 00       	push   $0x803310
  80212f:	e8 fe e6 ff ff       	call   800832 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802134:	83 ec 04             	sub    $0x4,%esp
  802137:	53                   	push   %ebx
  802138:	ff 75 0c             	pushl  0xc(%ebp)
  80213b:	68 0c 70 80 00       	push   $0x80700c
  802140:	e8 dd ee ff ff       	call   801022 <memmove>
	nsipcbuf.send.req_size = size;
  802145:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80214b:	8b 45 14             	mov    0x14(%ebp),%eax
  80214e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802153:	b8 08 00 00 00       	mov    $0x8,%eax
  802158:	e8 d9 fd ff ff       	call   801f36 <nsipc>
}
  80215d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802160:	c9                   	leave  
  802161:	c3                   	ret    

00802162 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802168:	8b 45 08             	mov    0x8(%ebp),%eax
  80216b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802170:	8b 45 0c             	mov    0xc(%ebp),%eax
  802173:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802178:	8b 45 10             	mov    0x10(%ebp),%eax
  80217b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802180:	b8 09 00 00 00       	mov    $0x9,%eax
  802185:	e8 ac fd ff ff       	call   801f36 <nsipc>
}
  80218a:	c9                   	leave  
  80218b:	c3                   	ret    

0080218c <free>:
	return v;
}

void
free(void *v)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	53                   	push   %ebx
  802190:	83 ec 04             	sub    $0x4,%esp
  802193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  802196:	85 db                	test   %ebx,%ebx
  802198:	0f 84 97 00 00 00    	je     802235 <free+0xa9>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  80219e:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  8021a4:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  8021a9:	76 16                	jbe    8021c1 <free+0x35>
  8021ab:	68 28 33 80 00       	push   $0x803328
  8021b0:	68 c3 32 80 00       	push   $0x8032c3
  8021b5:	6a 7a                	push   $0x7a
  8021b7:	68 58 33 80 00       	push   $0x803358
  8021bc:	e8 71 e6 ff ff       	call   800832 <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  8021c1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  8021c7:	eb 3a                	jmp    802203 <free+0x77>
		sys_page_unmap(0, c);
  8021c9:	83 ec 08             	sub    $0x8,%esp
  8021cc:	53                   	push   %ebx
  8021cd:	6a 00                	push   $0x0
  8021cf:	e8 44 f1 ff ff       	call   801318 <sys_page_unmap>
		c += PGSIZE;
  8021d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  8021da:	8d 83 00 00 00 f8    	lea    -0x8000000(%ebx),%eax
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	3d ff ff ff 07       	cmp    $0x7ffffff,%eax
  8021e8:	76 19                	jbe    802203 <free+0x77>
  8021ea:	68 65 33 80 00       	push   $0x803365
  8021ef:	68 c3 32 80 00       	push   $0x8032c3
  8021f4:	68 81 00 00 00       	push   $0x81
  8021f9:	68 58 33 80 00       	push   $0x803358
  8021fe:	e8 2f e6 ff ff       	call   800832 <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  802203:	89 d8                	mov    %ebx,%eax
  802205:	c1 e8 0c             	shr    $0xc,%eax
  802208:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80220f:	f6 c4 02             	test   $0x2,%ah
  802212:	75 b5                	jne    8021c9 <free+0x3d>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  802214:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  80221a:	83 e8 01             	sub    $0x1,%eax
  80221d:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  802223:	85 c0                	test   %eax,%eax
  802225:	75 0e                	jne    802235 <free+0xa9>
		sys_page_unmap(0, c);
  802227:	83 ec 08             	sub    $0x8,%esp
  80222a:	53                   	push   %ebx
  80222b:	6a 00                	push   $0x0
  80222d:	e8 e6 f0 ff ff       	call   801318 <sys_page_unmap>
  802232:	83 c4 10             	add    $0x10,%esp
}
  802235:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802238:	c9                   	leave  
  802239:	c3                   	ret    

0080223a <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	57                   	push   %edi
  80223e:	56                   	push   %esi
  80223f:	53                   	push   %ebx
  802240:	83 ec 1c             	sub    $0x1c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  802243:	a1 18 50 80 00       	mov    0x805018,%eax
  802248:	85 c0                	test   %eax,%eax
  80224a:	75 22                	jne    80226e <malloc+0x34>
		mptr = mbegin;
  80224c:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  802253:	00 00 08 

	n = ROUNDUP(n, 4);
  802256:	8b 45 08             	mov    0x8(%ebp),%eax
  802259:	83 c0 03             	add    $0x3,%eax
  80225c:	83 e0 fc             	and    $0xfffffffc,%eax
  80225f:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if (n >= MAXMALLOC)
  802262:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  802267:	76 74                	jbe    8022dd <malloc+0xa3>
  802269:	e9 7a 01 00 00       	jmp    8023e8 <malloc+0x1ae>
	void *v;

	if (mptr == 0)
		mptr = mbegin;

	n = ROUNDUP(n, 4);
  80226e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802271:	8d 53 03             	lea    0x3(%ebx),%edx
  802274:	83 e2 fc             	and    $0xfffffffc,%edx
  802277:	89 55 dc             	mov    %edx,-0x24(%ebp)

	if (n >= MAXMALLOC)
  80227a:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
  802280:	0f 87 69 01 00 00    	ja     8023ef <malloc+0x1b5>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  802286:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80228b:	74 50                	je     8022dd <malloc+0xa3>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  80228d:	89 c1                	mov    %eax,%ecx
  80228f:	c1 e9 0c             	shr    $0xc,%ecx
  802292:	8d 54 10 03          	lea    0x3(%eax,%edx,1),%edx
  802296:	c1 ea 0c             	shr    $0xc,%edx
  802299:	39 d1                	cmp    %edx,%ecx
  80229b:	75 20                	jne    8022bd <malloc+0x83>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  80229d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8022a3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  8022a9:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  8022ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8022b0:	01 c2                	add    %eax,%edx
  8022b2:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  8022b8:	e9 55 01 00 00       	jmp    802412 <malloc+0x1d8>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  8022bd:	83 ec 0c             	sub    $0xc,%esp
  8022c0:	50                   	push   %eax
  8022c1:	e8 c6 fe ff ff       	call   80218c <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  8022c6:	a1 18 50 80 00       	mov    0x805018,%eax
  8022cb:	05 00 10 00 00       	add    $0x1000,%eax
  8022d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8022d5:	a3 18 50 80 00       	mov    %eax,0x805018
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	8b 35 18 50 80 00    	mov    0x805018,%esi
	return 1;
}

void*
malloc(size_t n)
{
  8022e3:	c7 45 d8 02 00 00 00 	movl   $0x2,-0x28(%ebp)
  8022ea:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  8022ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8022f1:	8d 78 04             	lea    0x4(%eax),%edi
  8022f4:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8022f7:	89 fb                	mov    %edi,%ebx
  8022f9:	8d 0c 37             	lea    (%edi,%esi,1),%ecx
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  8022fc:	89 f0                	mov    %esi,%eax
  8022fe:	eb 36                	jmp    802336 <malloc+0xfc>
		if (va >= (uintptr_t) mend
  802300:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  802305:	0f 87 eb 00 00 00    	ja     8023f6 <malloc+0x1bc>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  80230b:	89 c2                	mov    %eax,%edx
  80230d:	c1 ea 16             	shr    $0x16,%edx
  802310:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802317:	f6 c2 01             	test   $0x1,%dl
  80231a:	74 15                	je     802331 <malloc+0xf7>
  80231c:	89 c2                	mov    %eax,%edx
  80231e:	c1 ea 0c             	shr    $0xc,%edx
  802321:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802328:	f6 c2 01             	test   $0x1,%dl
  80232b:	0f 85 c5 00 00 00    	jne    8023f6 <malloc+0x1bc>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802331:	05 00 10 00 00       	add    $0x1000,%eax
  802336:	39 c8                	cmp    %ecx,%eax
  802338:	72 c6                	jb     802300 <malloc+0xc6>
  80233a:	eb 79                	jmp    8023b5 <malloc+0x17b>
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  80233c:	be 00 00 00 08       	mov    $0x8000000,%esi
  802341:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
			if (++nwrap == 2)
  802345:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  802349:	75 a9                	jne    8022f4 <malloc+0xba>
  80234b:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  802352:	00 00 08 
				return 0;	/* out of address space */
  802355:	b8 00 00 00 00       	mov    $0x0,%eax
  80235a:	e9 b3 00 00 00       	jmp    802412 <malloc+0x1d8>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  80235f:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
  802365:	39 df                	cmp    %ebx,%edi
  802367:	19 c0                	sbb    %eax,%eax
  802369:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  80236e:	83 ec 04             	sub    $0x4,%esp
  802371:	83 c8 07             	or     $0x7,%eax
  802374:	50                   	push   %eax
  802375:	03 15 18 50 80 00    	add    0x805018,%edx
  80237b:	52                   	push   %edx
  80237c:	6a 00                	push   $0x0
  80237e:	e8 10 ef ff ff       	call   801293 <sys_page_alloc>
  802383:	83 c4 10             	add    $0x10,%esp
  802386:	85 c0                	test   %eax,%eax
  802388:	78 20                	js     8023aa <malloc+0x170>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  80238a:	89 fe                	mov    %edi,%esi
  80238c:	eb 3a                	jmp    8023c8 <malloc+0x18e>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  80238e:	83 ec 08             	sub    $0x8,%esp
  802391:	89 f0                	mov    %esi,%eax
  802393:	03 05 18 50 80 00    	add    0x805018,%eax
  802399:	50                   	push   %eax
  80239a:	6a 00                	push   $0x0
  80239c:	e8 77 ef ff ff       	call   801318 <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  8023a1:	81 ee 00 10 00 00    	sub    $0x1000,%esi
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	85 f6                	test   %esi,%esi
  8023ac:	79 e0                	jns    80238e <malloc+0x154>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  8023ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b3:	eb 5d                	jmp    802412 <malloc+0x1d8>
  8023b5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8023b9:	74 08                	je     8023c3 <malloc+0x189>
  8023bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023be:	a3 18 50 80 00       	mov    %eax,0x805018

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8023c3:	be 00 00 00 00       	mov    $0x0,%esi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  8023c8:	89 f2                	mov    %esi,%edx
  8023ca:	39 f3                	cmp    %esi,%ebx
  8023cc:	77 91                	ja     80235f <malloc+0x125>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  8023ce:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  8023d3:	c7 44 30 fc 02 00 00 	movl   $0x2,-0x4(%eax,%esi,1)
  8023da:	00 
	v = mptr;
	mptr += n;
  8023db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8023de:	01 c2                	add    %eax,%edx
  8023e0:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  8023e6:	eb 2a                	jmp    802412 <malloc+0x1d8>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  8023e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ed:	eb 23                	jmp    802412 <malloc+0x1d8>
  8023ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8023f4:	eb 1c                	jmp    802412 <malloc+0x1d8>
  8023f6:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
  8023fc:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
  802400:	89 c6                	mov    %eax,%esi
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  802402:	3d 00 00 00 10       	cmp    $0x10000000,%eax
  802407:	0f 85 e7 fe ff ff    	jne    8022f4 <malloc+0xba>
  80240d:	e9 2a ff ff ff       	jmp    80233c <malloc+0x102>
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  802412:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802415:	5b                   	pop    %ebx
  802416:	5e                   	pop    %esi
  802417:	5f                   	pop    %edi
  802418:	5d                   	pop    %ebp
  802419:	c3                   	ret    

0080241a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80241a:	55                   	push   %ebp
  80241b:	89 e5                	mov    %esp,%ebp
  80241d:	56                   	push   %esi
  80241e:	53                   	push   %ebx
  80241f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802422:	83 ec 0c             	sub    $0xc,%esp
  802425:	ff 75 08             	pushl  0x8(%ebp)
  802428:	e8 0a f1 ff ff       	call   801537 <fd2data>
  80242d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80242f:	83 c4 08             	add    $0x8,%esp
  802432:	68 7d 33 80 00       	push   $0x80337d
  802437:	53                   	push   %ebx
  802438:	e8 53 ea ff ff       	call   800e90 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80243d:	8b 46 04             	mov    0x4(%esi),%eax
  802440:	2b 06                	sub    (%esi),%eax
  802442:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802448:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80244f:	00 00 00 
	stat->st_dev = &devpipe;
  802452:	c7 83 88 00 00 00 5c 	movl   $0x80405c,0x88(%ebx)
  802459:	40 80 00 
	return 0;
}
  80245c:	b8 00 00 00 00       	mov    $0x0,%eax
  802461:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802464:	5b                   	pop    %ebx
  802465:	5e                   	pop    %esi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    

00802468 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802468:	55                   	push   %ebp
  802469:	89 e5                	mov    %esp,%ebp
  80246b:	53                   	push   %ebx
  80246c:	83 ec 0c             	sub    $0xc,%esp
  80246f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802472:	53                   	push   %ebx
  802473:	6a 00                	push   $0x0
  802475:	e8 9e ee ff ff       	call   801318 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80247a:	89 1c 24             	mov    %ebx,(%esp)
  80247d:	e8 b5 f0 ff ff       	call   801537 <fd2data>
  802482:	83 c4 08             	add    $0x8,%esp
  802485:	50                   	push   %eax
  802486:	6a 00                	push   $0x0
  802488:	e8 8b ee ff ff       	call   801318 <sys_page_unmap>
}
  80248d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802490:	c9                   	leave  
  802491:	c3                   	ret    

00802492 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802492:	55                   	push   %ebp
  802493:	89 e5                	mov    %esp,%ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	83 ec 1c             	sub    $0x1c,%esp
  80249b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80249e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8024a0:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8024a5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8024a8:	83 ec 0c             	sub    $0xc,%esp
  8024ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8024ae:	e8 3a 05 00 00       	call   8029ed <pageref>
  8024b3:	89 c3                	mov    %eax,%ebx
  8024b5:	89 3c 24             	mov    %edi,(%esp)
  8024b8:	e8 30 05 00 00       	call   8029ed <pageref>
  8024bd:	83 c4 10             	add    $0x10,%esp
  8024c0:	39 c3                	cmp    %eax,%ebx
  8024c2:	0f 94 c1             	sete   %cl
  8024c5:	0f b6 c9             	movzbl %cl,%ecx
  8024c8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8024cb:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  8024d1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8024d4:	39 ce                	cmp    %ecx,%esi
  8024d6:	74 1b                	je     8024f3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8024d8:	39 c3                	cmp    %eax,%ebx
  8024da:	75 c4                	jne    8024a0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024dc:	8b 42 58             	mov    0x58(%edx),%eax
  8024df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024e2:	50                   	push   %eax
  8024e3:	56                   	push   %esi
  8024e4:	68 84 33 80 00       	push   $0x803384
  8024e9:	e8 1d e4 ff ff       	call   80090b <cprintf>
  8024ee:	83 c4 10             	add    $0x10,%esp
  8024f1:	eb ad                	jmp    8024a0 <_pipeisclosed+0xe>
	}
}
  8024f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024f9:	5b                   	pop    %ebx
  8024fa:	5e                   	pop    %esi
  8024fb:	5f                   	pop    %edi
  8024fc:	5d                   	pop    %ebp
  8024fd:	c3                   	ret    

008024fe <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024fe:	55                   	push   %ebp
  8024ff:	89 e5                	mov    %esp,%ebp
  802501:	57                   	push   %edi
  802502:	56                   	push   %esi
  802503:	53                   	push   %ebx
  802504:	83 ec 28             	sub    $0x28,%esp
  802507:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80250a:	56                   	push   %esi
  80250b:	e8 27 f0 ff ff       	call   801537 <fd2data>
  802510:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802512:	83 c4 10             	add    $0x10,%esp
  802515:	bf 00 00 00 00       	mov    $0x0,%edi
  80251a:	eb 4b                	jmp    802567 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80251c:	89 da                	mov    %ebx,%edx
  80251e:	89 f0                	mov    %esi,%eax
  802520:	e8 6d ff ff ff       	call   802492 <_pipeisclosed>
  802525:	85 c0                	test   %eax,%eax
  802527:	75 48                	jne    802571 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802529:	e8 46 ed ff ff       	call   801274 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80252e:	8b 43 04             	mov    0x4(%ebx),%eax
  802531:	8b 0b                	mov    (%ebx),%ecx
  802533:	8d 51 20             	lea    0x20(%ecx),%edx
  802536:	39 d0                	cmp    %edx,%eax
  802538:	73 e2                	jae    80251c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80253a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80253d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802541:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802544:	89 c2                	mov    %eax,%edx
  802546:	c1 fa 1f             	sar    $0x1f,%edx
  802549:	89 d1                	mov    %edx,%ecx
  80254b:	c1 e9 1b             	shr    $0x1b,%ecx
  80254e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802551:	83 e2 1f             	and    $0x1f,%edx
  802554:	29 ca                	sub    %ecx,%edx
  802556:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80255a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80255e:	83 c0 01             	add    $0x1,%eax
  802561:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802564:	83 c7 01             	add    $0x1,%edi
  802567:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80256a:	75 c2                	jne    80252e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80256c:	8b 45 10             	mov    0x10(%ebp),%eax
  80256f:	eb 05                	jmp    802576 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802571:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802576:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802579:	5b                   	pop    %ebx
  80257a:	5e                   	pop    %esi
  80257b:	5f                   	pop    %edi
  80257c:	5d                   	pop    %ebp
  80257d:	c3                   	ret    

0080257e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80257e:	55                   	push   %ebp
  80257f:	89 e5                	mov    %esp,%ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 18             	sub    $0x18,%esp
  802587:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80258a:	57                   	push   %edi
  80258b:	e8 a7 ef ff ff       	call   801537 <fd2data>
  802590:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802592:	83 c4 10             	add    $0x10,%esp
  802595:	bb 00 00 00 00       	mov    $0x0,%ebx
  80259a:	eb 3d                	jmp    8025d9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80259c:	85 db                	test   %ebx,%ebx
  80259e:	74 04                	je     8025a4 <devpipe_read+0x26>
				return i;
  8025a0:	89 d8                	mov    %ebx,%eax
  8025a2:	eb 44                	jmp    8025e8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8025a4:	89 f2                	mov    %esi,%edx
  8025a6:	89 f8                	mov    %edi,%eax
  8025a8:	e8 e5 fe ff ff       	call   802492 <_pipeisclosed>
  8025ad:	85 c0                	test   %eax,%eax
  8025af:	75 32                	jne    8025e3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8025b1:	e8 be ec ff ff       	call   801274 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8025b6:	8b 06                	mov    (%esi),%eax
  8025b8:	3b 46 04             	cmp    0x4(%esi),%eax
  8025bb:	74 df                	je     80259c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025bd:	99                   	cltd   
  8025be:	c1 ea 1b             	shr    $0x1b,%edx
  8025c1:	01 d0                	add    %edx,%eax
  8025c3:	83 e0 1f             	and    $0x1f,%eax
  8025c6:	29 d0                	sub    %edx,%eax
  8025c8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8025cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025d0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8025d3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025d6:	83 c3 01             	add    $0x1,%ebx
  8025d9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025dc:	75 d8                	jne    8025b6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8025de:	8b 45 10             	mov    0x10(%ebp),%eax
  8025e1:	eb 05                	jmp    8025e8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025e3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8025e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025eb:	5b                   	pop    %ebx
  8025ec:	5e                   	pop    %esi
  8025ed:	5f                   	pop    %edi
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    

008025f0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	56                   	push   %esi
  8025f4:	53                   	push   %ebx
  8025f5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8025f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025fb:	50                   	push   %eax
  8025fc:	e8 4d ef ff ff       	call   80154e <fd_alloc>
  802601:	83 c4 10             	add    $0x10,%esp
  802604:	89 c2                	mov    %eax,%edx
  802606:	85 c0                	test   %eax,%eax
  802608:	0f 88 2c 01 00 00    	js     80273a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80260e:	83 ec 04             	sub    $0x4,%esp
  802611:	68 07 04 00 00       	push   $0x407
  802616:	ff 75 f4             	pushl  -0xc(%ebp)
  802619:	6a 00                	push   $0x0
  80261b:	e8 73 ec ff ff       	call   801293 <sys_page_alloc>
  802620:	83 c4 10             	add    $0x10,%esp
  802623:	89 c2                	mov    %eax,%edx
  802625:	85 c0                	test   %eax,%eax
  802627:	0f 88 0d 01 00 00    	js     80273a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80262d:	83 ec 0c             	sub    $0xc,%esp
  802630:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802633:	50                   	push   %eax
  802634:	e8 15 ef ff ff       	call   80154e <fd_alloc>
  802639:	89 c3                	mov    %eax,%ebx
  80263b:	83 c4 10             	add    $0x10,%esp
  80263e:	85 c0                	test   %eax,%eax
  802640:	0f 88 e2 00 00 00    	js     802728 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802646:	83 ec 04             	sub    $0x4,%esp
  802649:	68 07 04 00 00       	push   $0x407
  80264e:	ff 75 f0             	pushl  -0x10(%ebp)
  802651:	6a 00                	push   $0x0
  802653:	e8 3b ec ff ff       	call   801293 <sys_page_alloc>
  802658:	89 c3                	mov    %eax,%ebx
  80265a:	83 c4 10             	add    $0x10,%esp
  80265d:	85 c0                	test   %eax,%eax
  80265f:	0f 88 c3 00 00 00    	js     802728 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802665:	83 ec 0c             	sub    $0xc,%esp
  802668:	ff 75 f4             	pushl  -0xc(%ebp)
  80266b:	e8 c7 ee ff ff       	call   801537 <fd2data>
  802670:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802672:	83 c4 0c             	add    $0xc,%esp
  802675:	68 07 04 00 00       	push   $0x407
  80267a:	50                   	push   %eax
  80267b:	6a 00                	push   $0x0
  80267d:	e8 11 ec ff ff       	call   801293 <sys_page_alloc>
  802682:	89 c3                	mov    %eax,%ebx
  802684:	83 c4 10             	add    $0x10,%esp
  802687:	85 c0                	test   %eax,%eax
  802689:	0f 88 89 00 00 00    	js     802718 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80268f:	83 ec 0c             	sub    $0xc,%esp
  802692:	ff 75 f0             	pushl  -0x10(%ebp)
  802695:	e8 9d ee ff ff       	call   801537 <fd2data>
  80269a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8026a1:	50                   	push   %eax
  8026a2:	6a 00                	push   $0x0
  8026a4:	56                   	push   %esi
  8026a5:	6a 00                	push   $0x0
  8026a7:	e8 2a ec ff ff       	call   8012d6 <sys_page_map>
  8026ac:	89 c3                	mov    %eax,%ebx
  8026ae:	83 c4 20             	add    $0x20,%esp
  8026b1:	85 c0                	test   %eax,%eax
  8026b3:	78 55                	js     80270a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8026b5:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8026bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026be:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8026c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8026ca:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8026d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026d3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8026d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026d8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8026df:	83 ec 0c             	sub    $0xc,%esp
  8026e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8026e5:	e8 3d ee ff ff       	call   801527 <fd2num>
  8026ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026ed:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8026ef:	83 c4 04             	add    $0x4,%esp
  8026f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8026f5:	e8 2d ee ff ff       	call   801527 <fd2num>
  8026fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026fd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802700:	83 c4 10             	add    $0x10,%esp
  802703:	ba 00 00 00 00       	mov    $0x0,%edx
  802708:	eb 30                	jmp    80273a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80270a:	83 ec 08             	sub    $0x8,%esp
  80270d:	56                   	push   %esi
  80270e:	6a 00                	push   $0x0
  802710:	e8 03 ec ff ff       	call   801318 <sys_page_unmap>
  802715:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802718:	83 ec 08             	sub    $0x8,%esp
  80271b:	ff 75 f0             	pushl  -0x10(%ebp)
  80271e:	6a 00                	push   $0x0
  802720:	e8 f3 eb ff ff       	call   801318 <sys_page_unmap>
  802725:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802728:	83 ec 08             	sub    $0x8,%esp
  80272b:	ff 75 f4             	pushl  -0xc(%ebp)
  80272e:	6a 00                	push   $0x0
  802730:	e8 e3 eb ff ff       	call   801318 <sys_page_unmap>
  802735:	83 c4 10             	add    $0x10,%esp
  802738:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80273a:	89 d0                	mov    %edx,%eax
  80273c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80273f:	5b                   	pop    %ebx
  802740:	5e                   	pop    %esi
  802741:	5d                   	pop    %ebp
  802742:	c3                   	ret    

00802743 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802743:	55                   	push   %ebp
  802744:	89 e5                	mov    %esp,%ebp
  802746:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80274c:	50                   	push   %eax
  80274d:	ff 75 08             	pushl  0x8(%ebp)
  802750:	e8 48 ee ff ff       	call   80159d <fd_lookup>
  802755:	83 c4 10             	add    $0x10,%esp
  802758:	85 c0                	test   %eax,%eax
  80275a:	78 18                	js     802774 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80275c:	83 ec 0c             	sub    $0xc,%esp
  80275f:	ff 75 f4             	pushl  -0xc(%ebp)
  802762:	e8 d0 ed ff ff       	call   801537 <fd2data>
	return _pipeisclosed(fd, p);
  802767:	89 c2                	mov    %eax,%edx
  802769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80276c:	e8 21 fd ff ff       	call   802492 <_pipeisclosed>
  802771:	83 c4 10             	add    $0x10,%esp
}
  802774:	c9                   	leave  
  802775:	c3                   	ret    

00802776 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802776:	55                   	push   %ebp
  802777:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802779:	b8 00 00 00 00       	mov    $0x0,%eax
  80277e:	5d                   	pop    %ebp
  80277f:	c3                   	ret    

00802780 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802780:	55                   	push   %ebp
  802781:	89 e5                	mov    %esp,%ebp
  802783:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802786:	68 9c 33 80 00       	push   $0x80339c
  80278b:	ff 75 0c             	pushl  0xc(%ebp)
  80278e:	e8 fd e6 ff ff       	call   800e90 <strcpy>
	return 0;
}
  802793:	b8 00 00 00 00       	mov    $0x0,%eax
  802798:	c9                   	leave  
  802799:	c3                   	ret    

0080279a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80279a:	55                   	push   %ebp
  80279b:	89 e5                	mov    %esp,%ebp
  80279d:	57                   	push   %edi
  80279e:	56                   	push   %esi
  80279f:	53                   	push   %ebx
  8027a0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027a6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027b1:	eb 2d                	jmp    8027e0 <devcons_write+0x46>
		m = n - tot;
  8027b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027b6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8027b8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8027bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8027c0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027c3:	83 ec 04             	sub    $0x4,%esp
  8027c6:	53                   	push   %ebx
  8027c7:	03 45 0c             	add    0xc(%ebp),%eax
  8027ca:	50                   	push   %eax
  8027cb:	57                   	push   %edi
  8027cc:	e8 51 e8 ff ff       	call   801022 <memmove>
		sys_cputs(buf, m);
  8027d1:	83 c4 08             	add    $0x8,%esp
  8027d4:	53                   	push   %ebx
  8027d5:	57                   	push   %edi
  8027d6:	e8 fc e9 ff ff       	call   8011d7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027db:	01 de                	add    %ebx,%esi
  8027dd:	83 c4 10             	add    $0x10,%esp
  8027e0:	89 f0                	mov    %esi,%eax
  8027e2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027e5:	72 cc                	jb     8027b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027ea:	5b                   	pop    %ebx
  8027eb:	5e                   	pop    %esi
  8027ec:	5f                   	pop    %edi
  8027ed:	5d                   	pop    %ebp
  8027ee:	c3                   	ret    

008027ef <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027ef:	55                   	push   %ebp
  8027f0:	89 e5                	mov    %esp,%ebp
  8027f2:	83 ec 08             	sub    $0x8,%esp
  8027f5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8027fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027fe:	74 2a                	je     80282a <devcons_read+0x3b>
  802800:	eb 05                	jmp    802807 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802802:	e8 6d ea ff ff       	call   801274 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802807:	e8 e9 e9 ff ff       	call   8011f5 <sys_cgetc>
  80280c:	85 c0                	test   %eax,%eax
  80280e:	74 f2                	je     802802 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802810:	85 c0                	test   %eax,%eax
  802812:	78 16                	js     80282a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802814:	83 f8 04             	cmp    $0x4,%eax
  802817:	74 0c                	je     802825 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80281c:	88 02                	mov    %al,(%edx)
	return 1;
  80281e:	b8 01 00 00 00       	mov    $0x1,%eax
  802823:	eb 05                	jmp    80282a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802825:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80282a:	c9                   	leave  
  80282b:	c3                   	ret    

0080282c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80282c:	55                   	push   %ebp
  80282d:	89 e5                	mov    %esp,%ebp
  80282f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802832:	8b 45 08             	mov    0x8(%ebp),%eax
  802835:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802838:	6a 01                	push   $0x1
  80283a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80283d:	50                   	push   %eax
  80283e:	e8 94 e9 ff ff       	call   8011d7 <sys_cputs>
}
  802843:	83 c4 10             	add    $0x10,%esp
  802846:	c9                   	leave  
  802847:	c3                   	ret    

00802848 <getchar>:

int
getchar(void)
{
  802848:	55                   	push   %ebp
  802849:	89 e5                	mov    %esp,%ebp
  80284b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80284e:	6a 01                	push   $0x1
  802850:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802853:	50                   	push   %eax
  802854:	6a 00                	push   $0x0
  802856:	e8 a8 ef ff ff       	call   801803 <read>
	if (r < 0)
  80285b:	83 c4 10             	add    $0x10,%esp
  80285e:	85 c0                	test   %eax,%eax
  802860:	78 0f                	js     802871 <getchar+0x29>
		return r;
	if (r < 1)
  802862:	85 c0                	test   %eax,%eax
  802864:	7e 06                	jle    80286c <getchar+0x24>
		return -E_EOF;
	return c;
  802866:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80286a:	eb 05                	jmp    802871 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80286c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802871:	c9                   	leave  
  802872:	c3                   	ret    

00802873 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802873:	55                   	push   %ebp
  802874:	89 e5                	mov    %esp,%ebp
  802876:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802879:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80287c:	50                   	push   %eax
  80287d:	ff 75 08             	pushl  0x8(%ebp)
  802880:	e8 18 ed ff ff       	call   80159d <fd_lookup>
  802885:	83 c4 10             	add    $0x10,%esp
  802888:	85 c0                	test   %eax,%eax
  80288a:	78 11                	js     80289d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80288c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80288f:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802895:	39 10                	cmp    %edx,(%eax)
  802897:	0f 94 c0             	sete   %al
  80289a:	0f b6 c0             	movzbl %al,%eax
}
  80289d:	c9                   	leave  
  80289e:	c3                   	ret    

0080289f <opencons>:

int
opencons(void)
{
  80289f:	55                   	push   %ebp
  8028a0:	89 e5                	mov    %esp,%ebp
  8028a2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028a8:	50                   	push   %eax
  8028a9:	e8 a0 ec ff ff       	call   80154e <fd_alloc>
  8028ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8028b1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028b3:	85 c0                	test   %eax,%eax
  8028b5:	78 3e                	js     8028f5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028b7:	83 ec 04             	sub    $0x4,%esp
  8028ba:	68 07 04 00 00       	push   $0x407
  8028bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8028c2:	6a 00                	push   $0x0
  8028c4:	e8 ca e9 ff ff       	call   801293 <sys_page_alloc>
  8028c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8028cc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028ce:	85 c0                	test   %eax,%eax
  8028d0:	78 23                	js     8028f5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028d2:	8b 15 78 40 80 00    	mov    0x804078,%edx
  8028d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028db:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028e0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028e7:	83 ec 0c             	sub    $0xc,%esp
  8028ea:	50                   	push   %eax
  8028eb:	e8 37 ec ff ff       	call   801527 <fd2num>
  8028f0:	89 c2                	mov    %eax,%edx
  8028f2:	83 c4 10             	add    $0x10,%esp
}
  8028f5:	89 d0                	mov    %edx,%eax
  8028f7:	c9                   	leave  
  8028f8:	c3                   	ret    

008028f9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028f9:	55                   	push   %ebp
  8028fa:	89 e5                	mov    %esp,%ebp
  8028fc:	56                   	push   %esi
  8028fd:	53                   	push   %ebx
  8028fe:	8b 75 08             	mov    0x8(%ebp),%esi
  802901:	8b 45 0c             	mov    0xc(%ebp),%eax
  802904:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802907:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802909:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80290e:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802911:	83 ec 0c             	sub    $0xc,%esp
  802914:	50                   	push   %eax
  802915:	e8 29 eb ff ff       	call   801443 <sys_ipc_recv>

	if (from_env_store != NULL)
  80291a:	83 c4 10             	add    $0x10,%esp
  80291d:	85 f6                	test   %esi,%esi
  80291f:	74 14                	je     802935 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802921:	ba 00 00 00 00       	mov    $0x0,%edx
  802926:	85 c0                	test   %eax,%eax
  802928:	78 09                	js     802933 <ipc_recv+0x3a>
  80292a:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802930:	8b 52 74             	mov    0x74(%edx),%edx
  802933:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802935:	85 db                	test   %ebx,%ebx
  802937:	74 14                	je     80294d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802939:	ba 00 00 00 00       	mov    $0x0,%edx
  80293e:	85 c0                	test   %eax,%eax
  802940:	78 09                	js     80294b <ipc_recv+0x52>
  802942:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802948:	8b 52 78             	mov    0x78(%edx),%edx
  80294b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80294d:	85 c0                	test   %eax,%eax
  80294f:	78 08                	js     802959 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802951:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802956:	8b 40 70             	mov    0x70(%eax),%eax
}
  802959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80295c:	5b                   	pop    %ebx
  80295d:	5e                   	pop    %esi
  80295e:	5d                   	pop    %ebp
  80295f:	c3                   	ret    

00802960 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802960:	55                   	push   %ebp
  802961:	89 e5                	mov    %esp,%ebp
  802963:	57                   	push   %edi
  802964:	56                   	push   %esi
  802965:	53                   	push   %ebx
  802966:	83 ec 0c             	sub    $0xc,%esp
  802969:	8b 7d 08             	mov    0x8(%ebp),%edi
  80296c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80296f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802972:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802974:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802979:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80297c:	ff 75 14             	pushl  0x14(%ebp)
  80297f:	53                   	push   %ebx
  802980:	56                   	push   %esi
  802981:	57                   	push   %edi
  802982:	e8 99 ea ff ff       	call   801420 <sys_ipc_try_send>

		if (err < 0) {
  802987:	83 c4 10             	add    $0x10,%esp
  80298a:	85 c0                	test   %eax,%eax
  80298c:	79 1e                	jns    8029ac <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80298e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802991:	75 07                	jne    80299a <ipc_send+0x3a>
				sys_yield();
  802993:	e8 dc e8 ff ff       	call   801274 <sys_yield>
  802998:	eb e2                	jmp    80297c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80299a:	50                   	push   %eax
  80299b:	68 a8 33 80 00       	push   $0x8033a8
  8029a0:	6a 49                	push   $0x49
  8029a2:	68 b5 33 80 00       	push   $0x8033b5
  8029a7:	e8 86 de ff ff       	call   800832 <_panic>
		}

	} while (err < 0);

}
  8029ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029af:	5b                   	pop    %ebx
  8029b0:	5e                   	pop    %esi
  8029b1:	5f                   	pop    %edi
  8029b2:	5d                   	pop    %ebp
  8029b3:	c3                   	ret    

008029b4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029b4:	55                   	push   %ebp
  8029b5:	89 e5                	mov    %esp,%ebp
  8029b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029ba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029bf:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8029c2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029c8:	8b 52 50             	mov    0x50(%edx),%edx
  8029cb:	39 ca                	cmp    %ecx,%edx
  8029cd:	75 0d                	jne    8029dc <ipc_find_env+0x28>
			return envs[i].env_id;
  8029cf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029d7:	8b 40 48             	mov    0x48(%eax),%eax
  8029da:	eb 0f                	jmp    8029eb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8029dc:	83 c0 01             	add    $0x1,%eax
  8029df:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029e4:	75 d9                	jne    8029bf <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8029e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8029eb:	5d                   	pop    %ebp
  8029ec:	c3                   	ret    

008029ed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029ed:	55                   	push   %ebp
  8029ee:	89 e5                	mov    %esp,%ebp
  8029f0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029f3:	89 d0                	mov    %edx,%eax
  8029f5:	c1 e8 16             	shr    $0x16,%eax
  8029f8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8029ff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a04:	f6 c1 01             	test   $0x1,%cl
  802a07:	74 1d                	je     802a26 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802a09:	c1 ea 0c             	shr    $0xc,%edx
  802a0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802a13:	f6 c2 01             	test   $0x1,%dl
  802a16:	74 0e                	je     802a26 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a18:	c1 ea 0c             	shr    $0xc,%edx
  802a1b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802a22:	ef 
  802a23:	0f b7 c0             	movzwl %ax,%eax
}
  802a26:	5d                   	pop    %ebp
  802a27:	c3                   	ret    
  802a28:	66 90                	xchg   %ax,%ax
  802a2a:	66 90                	xchg   %ax,%ax
  802a2c:	66 90                	xchg   %ax,%ax
  802a2e:	66 90                	xchg   %ax,%ax

00802a30 <__udivdi3>:
  802a30:	55                   	push   %ebp
  802a31:	57                   	push   %edi
  802a32:	56                   	push   %esi
  802a33:	53                   	push   %ebx
  802a34:	83 ec 1c             	sub    $0x1c,%esp
  802a37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802a3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802a3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802a43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802a47:	85 f6                	test   %esi,%esi
  802a49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a4d:	89 ca                	mov    %ecx,%edx
  802a4f:	89 f8                	mov    %edi,%eax
  802a51:	75 3d                	jne    802a90 <__udivdi3+0x60>
  802a53:	39 cf                	cmp    %ecx,%edi
  802a55:	0f 87 c5 00 00 00    	ja     802b20 <__udivdi3+0xf0>
  802a5b:	85 ff                	test   %edi,%edi
  802a5d:	89 fd                	mov    %edi,%ebp
  802a5f:	75 0b                	jne    802a6c <__udivdi3+0x3c>
  802a61:	b8 01 00 00 00       	mov    $0x1,%eax
  802a66:	31 d2                	xor    %edx,%edx
  802a68:	f7 f7                	div    %edi
  802a6a:	89 c5                	mov    %eax,%ebp
  802a6c:	89 c8                	mov    %ecx,%eax
  802a6e:	31 d2                	xor    %edx,%edx
  802a70:	f7 f5                	div    %ebp
  802a72:	89 c1                	mov    %eax,%ecx
  802a74:	89 d8                	mov    %ebx,%eax
  802a76:	89 cf                	mov    %ecx,%edi
  802a78:	f7 f5                	div    %ebp
  802a7a:	89 c3                	mov    %eax,%ebx
  802a7c:	89 d8                	mov    %ebx,%eax
  802a7e:	89 fa                	mov    %edi,%edx
  802a80:	83 c4 1c             	add    $0x1c,%esp
  802a83:	5b                   	pop    %ebx
  802a84:	5e                   	pop    %esi
  802a85:	5f                   	pop    %edi
  802a86:	5d                   	pop    %ebp
  802a87:	c3                   	ret    
  802a88:	90                   	nop
  802a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a90:	39 ce                	cmp    %ecx,%esi
  802a92:	77 74                	ja     802b08 <__udivdi3+0xd8>
  802a94:	0f bd fe             	bsr    %esi,%edi
  802a97:	83 f7 1f             	xor    $0x1f,%edi
  802a9a:	0f 84 98 00 00 00    	je     802b38 <__udivdi3+0x108>
  802aa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802aa5:	89 f9                	mov    %edi,%ecx
  802aa7:	89 c5                	mov    %eax,%ebp
  802aa9:	29 fb                	sub    %edi,%ebx
  802aab:	d3 e6                	shl    %cl,%esi
  802aad:	89 d9                	mov    %ebx,%ecx
  802aaf:	d3 ed                	shr    %cl,%ebp
  802ab1:	89 f9                	mov    %edi,%ecx
  802ab3:	d3 e0                	shl    %cl,%eax
  802ab5:	09 ee                	or     %ebp,%esi
  802ab7:	89 d9                	mov    %ebx,%ecx
  802ab9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802abd:	89 d5                	mov    %edx,%ebp
  802abf:	8b 44 24 08          	mov    0x8(%esp),%eax
  802ac3:	d3 ed                	shr    %cl,%ebp
  802ac5:	89 f9                	mov    %edi,%ecx
  802ac7:	d3 e2                	shl    %cl,%edx
  802ac9:	89 d9                	mov    %ebx,%ecx
  802acb:	d3 e8                	shr    %cl,%eax
  802acd:	09 c2                	or     %eax,%edx
  802acf:	89 d0                	mov    %edx,%eax
  802ad1:	89 ea                	mov    %ebp,%edx
  802ad3:	f7 f6                	div    %esi
  802ad5:	89 d5                	mov    %edx,%ebp
  802ad7:	89 c3                	mov    %eax,%ebx
  802ad9:	f7 64 24 0c          	mull   0xc(%esp)
  802add:	39 d5                	cmp    %edx,%ebp
  802adf:	72 10                	jb     802af1 <__udivdi3+0xc1>
  802ae1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ae5:	89 f9                	mov    %edi,%ecx
  802ae7:	d3 e6                	shl    %cl,%esi
  802ae9:	39 c6                	cmp    %eax,%esi
  802aeb:	73 07                	jae    802af4 <__udivdi3+0xc4>
  802aed:	39 d5                	cmp    %edx,%ebp
  802aef:	75 03                	jne    802af4 <__udivdi3+0xc4>
  802af1:	83 eb 01             	sub    $0x1,%ebx
  802af4:	31 ff                	xor    %edi,%edi
  802af6:	89 d8                	mov    %ebx,%eax
  802af8:	89 fa                	mov    %edi,%edx
  802afa:	83 c4 1c             	add    $0x1c,%esp
  802afd:	5b                   	pop    %ebx
  802afe:	5e                   	pop    %esi
  802aff:	5f                   	pop    %edi
  802b00:	5d                   	pop    %ebp
  802b01:	c3                   	ret    
  802b02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b08:	31 ff                	xor    %edi,%edi
  802b0a:	31 db                	xor    %ebx,%ebx
  802b0c:	89 d8                	mov    %ebx,%eax
  802b0e:	89 fa                	mov    %edi,%edx
  802b10:	83 c4 1c             	add    $0x1c,%esp
  802b13:	5b                   	pop    %ebx
  802b14:	5e                   	pop    %esi
  802b15:	5f                   	pop    %edi
  802b16:	5d                   	pop    %ebp
  802b17:	c3                   	ret    
  802b18:	90                   	nop
  802b19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b20:	89 d8                	mov    %ebx,%eax
  802b22:	f7 f7                	div    %edi
  802b24:	31 ff                	xor    %edi,%edi
  802b26:	89 c3                	mov    %eax,%ebx
  802b28:	89 d8                	mov    %ebx,%eax
  802b2a:	89 fa                	mov    %edi,%edx
  802b2c:	83 c4 1c             	add    $0x1c,%esp
  802b2f:	5b                   	pop    %ebx
  802b30:	5e                   	pop    %esi
  802b31:	5f                   	pop    %edi
  802b32:	5d                   	pop    %ebp
  802b33:	c3                   	ret    
  802b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b38:	39 ce                	cmp    %ecx,%esi
  802b3a:	72 0c                	jb     802b48 <__udivdi3+0x118>
  802b3c:	31 db                	xor    %ebx,%ebx
  802b3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802b42:	0f 87 34 ff ff ff    	ja     802a7c <__udivdi3+0x4c>
  802b48:	bb 01 00 00 00       	mov    $0x1,%ebx
  802b4d:	e9 2a ff ff ff       	jmp    802a7c <__udivdi3+0x4c>
  802b52:	66 90                	xchg   %ax,%ax
  802b54:	66 90                	xchg   %ax,%ax
  802b56:	66 90                	xchg   %ax,%ax
  802b58:	66 90                	xchg   %ax,%ax
  802b5a:	66 90                	xchg   %ax,%ax
  802b5c:	66 90                	xchg   %ax,%ax
  802b5e:	66 90                	xchg   %ax,%ax

00802b60 <__umoddi3>:
  802b60:	55                   	push   %ebp
  802b61:	57                   	push   %edi
  802b62:	56                   	push   %esi
  802b63:	53                   	push   %ebx
  802b64:	83 ec 1c             	sub    $0x1c,%esp
  802b67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b77:	85 d2                	test   %edx,%edx
  802b79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b81:	89 f3                	mov    %esi,%ebx
  802b83:	89 3c 24             	mov    %edi,(%esp)
  802b86:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b8a:	75 1c                	jne    802ba8 <__umoddi3+0x48>
  802b8c:	39 f7                	cmp    %esi,%edi
  802b8e:	76 50                	jbe    802be0 <__umoddi3+0x80>
  802b90:	89 c8                	mov    %ecx,%eax
  802b92:	89 f2                	mov    %esi,%edx
  802b94:	f7 f7                	div    %edi
  802b96:	89 d0                	mov    %edx,%eax
  802b98:	31 d2                	xor    %edx,%edx
  802b9a:	83 c4 1c             	add    $0x1c,%esp
  802b9d:	5b                   	pop    %ebx
  802b9e:	5e                   	pop    %esi
  802b9f:	5f                   	pop    %edi
  802ba0:	5d                   	pop    %ebp
  802ba1:	c3                   	ret    
  802ba2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ba8:	39 f2                	cmp    %esi,%edx
  802baa:	89 d0                	mov    %edx,%eax
  802bac:	77 52                	ja     802c00 <__umoddi3+0xa0>
  802bae:	0f bd ea             	bsr    %edx,%ebp
  802bb1:	83 f5 1f             	xor    $0x1f,%ebp
  802bb4:	75 5a                	jne    802c10 <__umoddi3+0xb0>
  802bb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802bba:	0f 82 e0 00 00 00    	jb     802ca0 <__umoddi3+0x140>
  802bc0:	39 0c 24             	cmp    %ecx,(%esp)
  802bc3:	0f 86 d7 00 00 00    	jbe    802ca0 <__umoddi3+0x140>
  802bc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  802bcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802bd1:	83 c4 1c             	add    $0x1c,%esp
  802bd4:	5b                   	pop    %ebx
  802bd5:	5e                   	pop    %esi
  802bd6:	5f                   	pop    %edi
  802bd7:	5d                   	pop    %ebp
  802bd8:	c3                   	ret    
  802bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802be0:	85 ff                	test   %edi,%edi
  802be2:	89 fd                	mov    %edi,%ebp
  802be4:	75 0b                	jne    802bf1 <__umoddi3+0x91>
  802be6:	b8 01 00 00 00       	mov    $0x1,%eax
  802beb:	31 d2                	xor    %edx,%edx
  802bed:	f7 f7                	div    %edi
  802bef:	89 c5                	mov    %eax,%ebp
  802bf1:	89 f0                	mov    %esi,%eax
  802bf3:	31 d2                	xor    %edx,%edx
  802bf5:	f7 f5                	div    %ebp
  802bf7:	89 c8                	mov    %ecx,%eax
  802bf9:	f7 f5                	div    %ebp
  802bfb:	89 d0                	mov    %edx,%eax
  802bfd:	eb 99                	jmp    802b98 <__umoddi3+0x38>
  802bff:	90                   	nop
  802c00:	89 c8                	mov    %ecx,%eax
  802c02:	89 f2                	mov    %esi,%edx
  802c04:	83 c4 1c             	add    $0x1c,%esp
  802c07:	5b                   	pop    %ebx
  802c08:	5e                   	pop    %esi
  802c09:	5f                   	pop    %edi
  802c0a:	5d                   	pop    %ebp
  802c0b:	c3                   	ret    
  802c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c10:	8b 34 24             	mov    (%esp),%esi
  802c13:	bf 20 00 00 00       	mov    $0x20,%edi
  802c18:	89 e9                	mov    %ebp,%ecx
  802c1a:	29 ef                	sub    %ebp,%edi
  802c1c:	d3 e0                	shl    %cl,%eax
  802c1e:	89 f9                	mov    %edi,%ecx
  802c20:	89 f2                	mov    %esi,%edx
  802c22:	d3 ea                	shr    %cl,%edx
  802c24:	89 e9                	mov    %ebp,%ecx
  802c26:	09 c2                	or     %eax,%edx
  802c28:	89 d8                	mov    %ebx,%eax
  802c2a:	89 14 24             	mov    %edx,(%esp)
  802c2d:	89 f2                	mov    %esi,%edx
  802c2f:	d3 e2                	shl    %cl,%edx
  802c31:	89 f9                	mov    %edi,%ecx
  802c33:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802c3b:	d3 e8                	shr    %cl,%eax
  802c3d:	89 e9                	mov    %ebp,%ecx
  802c3f:	89 c6                	mov    %eax,%esi
  802c41:	d3 e3                	shl    %cl,%ebx
  802c43:	89 f9                	mov    %edi,%ecx
  802c45:	89 d0                	mov    %edx,%eax
  802c47:	d3 e8                	shr    %cl,%eax
  802c49:	89 e9                	mov    %ebp,%ecx
  802c4b:	09 d8                	or     %ebx,%eax
  802c4d:	89 d3                	mov    %edx,%ebx
  802c4f:	89 f2                	mov    %esi,%edx
  802c51:	f7 34 24             	divl   (%esp)
  802c54:	89 d6                	mov    %edx,%esi
  802c56:	d3 e3                	shl    %cl,%ebx
  802c58:	f7 64 24 04          	mull   0x4(%esp)
  802c5c:	39 d6                	cmp    %edx,%esi
  802c5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c62:	89 d1                	mov    %edx,%ecx
  802c64:	89 c3                	mov    %eax,%ebx
  802c66:	72 08                	jb     802c70 <__umoddi3+0x110>
  802c68:	75 11                	jne    802c7b <__umoddi3+0x11b>
  802c6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c6e:	73 0b                	jae    802c7b <__umoddi3+0x11b>
  802c70:	2b 44 24 04          	sub    0x4(%esp),%eax
  802c74:	1b 14 24             	sbb    (%esp),%edx
  802c77:	89 d1                	mov    %edx,%ecx
  802c79:	89 c3                	mov    %eax,%ebx
  802c7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802c7f:	29 da                	sub    %ebx,%edx
  802c81:	19 ce                	sbb    %ecx,%esi
  802c83:	89 f9                	mov    %edi,%ecx
  802c85:	89 f0                	mov    %esi,%eax
  802c87:	d3 e0                	shl    %cl,%eax
  802c89:	89 e9                	mov    %ebp,%ecx
  802c8b:	d3 ea                	shr    %cl,%edx
  802c8d:	89 e9                	mov    %ebp,%ecx
  802c8f:	d3 ee                	shr    %cl,%esi
  802c91:	09 d0                	or     %edx,%eax
  802c93:	89 f2                	mov    %esi,%edx
  802c95:	83 c4 1c             	add    $0x1c,%esp
  802c98:	5b                   	pop    %ebx
  802c99:	5e                   	pop    %esi
  802c9a:	5f                   	pop    %edi
  802c9b:	5d                   	pop    %ebp
  802c9c:	c3                   	ret    
  802c9d:	8d 76 00             	lea    0x0(%esi),%esi
  802ca0:	29 f9                	sub    %edi,%ecx
  802ca2:	19 d6                	sbb    %edx,%esi
  802ca4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ca8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cac:	e9 18 ff ff ff       	jmp    802bc9 <__umoddi3+0x69>
