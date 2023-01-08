
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 91 04 00 00       	call   8004c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 f0 26 80 00       	push   $0x8026f0
  80003f:	e8 71 05 00 00       	call   8005b5 <cprintf>
	exit();
  800044:	e8 bf 04 00 00       	call   800508 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:

void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 30             	sub    $0x30,%esp
  800057:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005a:	6a 20                	push   $0x20
  80005c:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	56                   	push   %esi
  800061:	e8 c3 13 00 00       	call   801429 <read>
  800066:	89 c3                	mov    %eax,%ebx
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	79 0a                	jns    800079 <handle_client+0x2b>
		die("Failed to receive initial bytes from client");
  80006f:	b8 f4 26 80 00       	mov    $0x8026f4,%eax
  800074:	e8 ba ff ff ff       	call   800033 <die>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  800079:	8d 7d c8             	lea    -0x38(%ebp),%edi
  80007c:	eb 3b                	jmp    8000b9 <handle_client+0x6b>
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	53                   	push   %ebx
  800082:	57                   	push   %edi
  800083:	56                   	push   %esi
  800084:	e8 7a 14 00 00       	call   801503 <write>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	39 c3                	cmp    %eax,%ebx
  80008e:	74 0a                	je     80009a <handle_client+0x4c>
			die("Failed to send bytes to client");
  800090:	b8 20 27 80 00       	mov    $0x802720,%eax
  800095:	e8 99 ff ff ff       	call   800033 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	6a 20                	push   $0x20
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	e8 83 13 00 00       	call   801429 <read>
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 0a                	jns    8000b9 <handle_client+0x6b>
			die("Failed to receive additional bytes from client");
  8000af:	b8 40 27 80 00       	mov    $0x802740,%eax
  8000b4:	e8 7a ff ff ff       	call   800033 <die>
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000b9:	85 db                	test   %ebx,%ebx
  8000bb:	7f c1                	jg     80007e <handle_client+0x30>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	56                   	push   %esi
  8000c1:	e8 27 12 00 00       	call   8012ed <close>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <umain>:

void
umain(int argc, char **argv)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 40             	sub    $0x40,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000da:	6a 06                	push   $0x6
  8000dc:	6a 01                	push   $0x1
  8000de:	6a 02                	push   $0x2
  8000e0:	e8 b1 1d 00 00       	call   801e96 <socket>
  8000e5:	89 c6                	mov    %eax,%esi
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	79 0a                	jns    8000f8 <umain+0x27>
		die("Failed to create socket");
  8000ee:	b8 a0 26 80 00       	mov    $0x8026a0,%eax
  8000f3:	e8 3b ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	68 b8 26 80 00       	push   $0x8026b8
  800100:	e8 b0 04 00 00       	call   8005b5 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800105:	83 c4 0c             	add    $0xc,%esp
  800108:	6a 10                	push   $0x10
  80010a:	6a 00                	push   $0x0
  80010c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80010f:	53                   	push   %ebx
  800110:	e8 6a 0b 00 00       	call   800c7f <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  800115:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800120:	e8 6c 01 00 00       	call   800291 <htonl>
  800125:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800128:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80012f:	e8 43 01 00 00       	call   800277 <htons>
  800134:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800138:	c7 04 24 c7 26 80 00 	movl   $0x8026c7,(%esp)
  80013f:	e8 71 04 00 00       	call   8005b5 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  800144:	83 c4 0c             	add    $0xc,%esp
  800147:	6a 10                	push   $0x10
  800149:	53                   	push   %ebx
  80014a:	56                   	push   %esi
  80014b:	e8 b4 1c 00 00       	call   801e04 <bind>
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	85 c0                	test   %eax,%eax
  800155:	79 0a                	jns    800161 <umain+0x90>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800157:	b8 70 27 80 00       	mov    $0x802770,%eax
  80015c:	e8 d2 fe ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	6a 05                	push   $0x5
  800166:	56                   	push   %esi
  800167:	e8 07 1d 00 00       	call   801e73 <listen>
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	85 c0                	test   %eax,%eax
  800171:	79 0a                	jns    80017d <umain+0xac>
		die("Failed to listen on server socket");
  800173:	b8 94 27 80 00       	mov    $0x802794,%eax
  800178:	e8 b6 fe ff ff       	call   800033 <die>

	cprintf("bound\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 d7 26 80 00       	push   $0x8026d7
  800185:	e8 2b 04 00 00       	call   8005b5 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  80018d:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  800190:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	57                   	push   %edi
  80019b:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	56                   	push   %esi
  8001a0:	e8 28 1c 00 00       	call   801dcd <accept>
  8001a5:	89 c3                	mov    %eax,%ebx
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	79 0a                	jns    8001b8 <umain+0xe7>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001ae:	b8 b8 27 80 00       	mov    $0x8027b8,%eax
  8001b3:	e8 7b fe ff ff       	call   800033 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	ff 75 cc             	pushl  -0x34(%ebp)
  8001be:	e8 1b 00 00 00       	call   8001de <inet_ntoa>
  8001c3:	83 c4 08             	add    $0x8,%esp
  8001c6:	50                   	push   %eax
  8001c7:	68 de 26 80 00       	push   $0x8026de
  8001cc:	e8 e4 03 00 00       	call   8005b5 <cprintf>
		handle_client(clientsock);
  8001d1:	89 1c 24             	mov    %ebx,(%esp)
  8001d4:	e8 75 fe ff ff       	call   80004e <handle_client>
	}
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb b2                	jmp    800190 <umain+0xbf>

008001de <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	57                   	push   %edi
  8001e2:	56                   	push   %esi
  8001e3:	53                   	push   %ebx
  8001e4:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001f0:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001f7:	0f b6 0f             	movzbl (%edi),%ecx
  8001fa:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001ff:	0f b6 d9             	movzbl %cl,%ebx
  800202:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800205:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800208:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80020b:	66 c1 e8 0b          	shr    $0xb,%ax
  80020f:	89 c3                	mov    %eax,%ebx
  800211:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800214:	01 c0                	add    %eax,%eax
  800216:	29 c1                	sub    %eax,%ecx
  800218:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  80021a:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80021c:	8d 72 01             	lea    0x1(%edx),%esi
  80021f:	0f b6 d2             	movzbl %dl,%edx
  800222:	83 c0 30             	add    $0x30,%eax
  800225:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800229:	89 f2                	mov    %esi,%edx
    } while(*ap);
  80022b:	84 db                	test   %bl,%bl
  80022d:	75 d0                	jne    8001ff <inet_ntoa+0x21>
  80022f:	c6 07 00             	movb   $0x0,(%edi)
  800232:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800235:	eb 0d                	jmp    800244 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800237:	0f b6 c2             	movzbl %dl,%eax
  80023a:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  80023f:	88 01                	mov    %al,(%ecx)
  800241:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800244:	83 ea 01             	sub    $0x1,%edx
  800247:	80 fa ff             	cmp    $0xff,%dl
  80024a:	75 eb                	jne    800237 <inet_ntoa+0x59>
  80024c:	89 f0                	mov    %esi,%eax
  80024e:	0f b6 f0             	movzbl %al,%esi
  800251:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  800254:	8d 46 01             	lea    0x1(%esi),%eax
  800257:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025a:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  80025d:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800263:	39 c7                	cmp    %eax,%edi
  800265:	75 90                	jne    8001f7 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800267:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  80026a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80027a:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80027e:	66 c1 c0 08          	rol    $0x8,%ax
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800287:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80028b:	66 c1 c0 08          	rol    $0x8,%ax
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800297:	89 d1                	mov    %edx,%ecx
  800299:	c1 e1 18             	shl    $0x18,%ecx
  80029c:	89 d0                	mov    %edx,%eax
  80029e:	c1 e8 18             	shr    $0x18,%eax
  8002a1:	09 c8                	or     %ecx,%eax
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002ab:	c1 e1 08             	shl    $0x8,%ecx
  8002ae:	09 c8                	or     %ecx,%eax
  8002b0:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002b6:	c1 ea 08             	shr    $0x8,%edx
  8002b9:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 20             	sub    $0x20,%esp
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002c9:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002cc:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002cf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002d2:	0f b6 ca             	movzbl %dl,%ecx
  8002d5:	83 e9 30             	sub    $0x30,%ecx
  8002d8:	83 f9 09             	cmp    $0x9,%ecx
  8002db:	0f 87 94 01 00 00    	ja     800475 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002e1:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002e8:	83 fa 30             	cmp    $0x30,%edx
  8002eb:	75 2b                	jne    800318 <inet_aton+0x5b>
      c = *++cp;
  8002ed:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002f1:	89 d1                	mov    %edx,%ecx
  8002f3:	83 e1 df             	and    $0xffffffdf,%ecx
  8002f6:	80 f9 58             	cmp    $0x58,%cl
  8002f9:	74 0f                	je     80030a <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002fb:	83 c0 01             	add    $0x1,%eax
  8002fe:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800301:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800308:	eb 0e                	jmp    800318 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80030a:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80030e:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800311:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800318:	83 c0 01             	add    $0x1,%eax
  80031b:	be 00 00 00 00       	mov    $0x0,%esi
  800320:	eb 03                	jmp    800325 <inet_aton+0x68>
  800322:	83 c0 01             	add    $0x1,%eax
  800325:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800328:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80032b:	0f b6 fa             	movzbl %dl,%edi
  80032e:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800331:	83 f9 09             	cmp    $0x9,%ecx
  800334:	77 0d                	ja     800343 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800336:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  80033a:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  80033e:	0f be 10             	movsbl (%eax),%edx
  800341:	eb df                	jmp    800322 <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  800343:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800347:	75 32                	jne    80037b <inet_aton+0xbe>
  800349:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  80034c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80034f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800352:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800358:	83 e9 41             	sub    $0x41,%ecx
  80035b:	83 f9 05             	cmp    $0x5,%ecx
  80035e:	77 1b                	ja     80037b <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800360:	c1 e6 04             	shl    $0x4,%esi
  800363:	83 c2 0a             	add    $0xa,%edx
  800366:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  80036a:	19 c9                	sbb    %ecx,%ecx
  80036c:	83 e1 20             	and    $0x20,%ecx
  80036f:	83 c1 41             	add    $0x41,%ecx
  800372:	29 ca                	sub    %ecx,%edx
  800374:	09 d6                	or     %edx,%esi
        c = *++cp;
  800376:	0f be 10             	movsbl (%eax),%edx
  800379:	eb a7                	jmp    800322 <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  80037b:	83 fa 2e             	cmp    $0x2e,%edx
  80037e:	75 23                	jne    8003a3 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800380:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800383:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800386:	39 f8                	cmp    %edi,%eax
  800388:	0f 84 ee 00 00 00    	je     80047c <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  80038e:	83 c0 04             	add    $0x4,%eax
  800391:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800394:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800397:	8d 43 01             	lea    0x1(%ebx),%eax
  80039a:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  80039e:	e9 2f ff ff ff       	jmp    8002d2 <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003a3:	85 d2                	test   %edx,%edx
  8003a5:	74 25                	je     8003cc <inet_aton+0x10f>
  8003a7:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003af:	83 f9 5f             	cmp    $0x5f,%ecx
  8003b2:	0f 87 d0 00 00 00    	ja     800488 <inet_aton+0x1cb>
  8003b8:	83 fa 20             	cmp    $0x20,%edx
  8003bb:	74 0f                	je     8003cc <inet_aton+0x10f>
  8003bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c0:	83 ea 09             	sub    $0x9,%edx
  8003c3:	83 fa 04             	cmp    $0x4,%edx
  8003c6:	0f 87 bc 00 00 00    	ja     800488 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003d2:	29 c2                	sub    %eax,%edx
  8003d4:	c1 fa 02             	sar    $0x2,%edx
  8003d7:	83 c2 01             	add    $0x1,%edx
  8003da:	83 fa 02             	cmp    $0x2,%edx
  8003dd:	74 20                	je     8003ff <inet_aton+0x142>
  8003df:	83 fa 02             	cmp    $0x2,%edx
  8003e2:	7f 0f                	jg     8003f3 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	0f 84 97 00 00 00    	je     800488 <inet_aton+0x1cb>
  8003f1:	eb 67                	jmp    80045a <inet_aton+0x19d>
  8003f3:	83 fa 03             	cmp    $0x3,%edx
  8003f6:	74 1e                	je     800416 <inet_aton+0x159>
  8003f8:	83 fa 04             	cmp    $0x4,%edx
  8003fb:	74 38                	je     800435 <inet_aton+0x178>
  8003fd:	eb 5b                	jmp    80045a <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800404:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  80040a:	77 7c                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  80040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040f:	c1 e0 18             	shl    $0x18,%eax
  800412:	09 c6                	or     %eax,%esi
    break;
  800414:	eb 44                	jmp    80045a <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80041b:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800421:	77 65                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800426:	c1 e2 18             	shl    $0x18,%edx
  800429:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80042c:	c1 e0 10             	shl    $0x10,%eax
  80042f:	09 d0                	or     %edx,%eax
  800431:	09 c6                	or     %eax,%esi
    break;
  800433:	eb 25                	jmp    80045a <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80043a:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800440:	77 46                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800445:	c1 e2 18             	shl    $0x18,%edx
  800448:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80044b:	c1 e0 10             	shl    $0x10,%eax
  80044e:	09 c2                	or     %eax,%edx
  800450:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800453:	c1 e0 08             	shl    $0x8,%eax
  800456:	09 d0                	or     %edx,%eax
  800458:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  80045a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80045e:	74 23                	je     800483 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800460:	56                   	push   %esi
  800461:	e8 2b fe ff ff       	call   800291 <htonl>
  800466:	83 c4 04             	add    $0x4,%esp
  800469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80046c:	89 03                	mov    %eax,(%ebx)
  return (1);
  80046e:	b8 01 00 00 00       	mov    $0x1,%eax
  800473:	eb 13                	jmp    800488 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	eb 0c                	jmp    800488 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	eb 05                	jmp    800488 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800483:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800496:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800499:	50                   	push   %eax
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	e8 1b fe ff ff       	call   8002bd <inet_aton>
  8004a2:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004ac:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	e8 d4 fd ff ff       	call   800291 <htonl>
  8004bd:	83 c4 04             	add    $0x4,%esp
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	56                   	push   %esi
  8004c6:	53                   	push   %ebx
  8004c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8004cd:	e8 2d 0a 00 00       	call   800eff <sys_getenvid>
  8004d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004df:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7e 07                	jle    8004ef <libmain+0x2d>
		binaryname = argv[0];
  8004e8:	8b 06                	mov    (%esi),%eax
  8004ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	e8 d8 fb ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  8004f9:	e8 0a 00 00 00       	call   800508 <exit>
}
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80050e:	e8 05 0e 00 00       	call   801318 <close_all>
	sys_env_destroy(0);
  800513:	83 ec 0c             	sub    $0xc,%esp
  800516:	6a 00                	push   $0x0
  800518:	e8 a1 09 00 00       	call   800ebe <sys_env_destroy>
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80052c:	8b 13                	mov    (%ebx),%edx
  80052e:	8d 42 01             	lea    0x1(%edx),%eax
  800531:	89 03                	mov    %eax,(%ebx)
  800533:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800536:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80053a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80053f:	75 1a                	jne    80055b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	68 ff 00 00 00       	push   $0xff
  800549:	8d 43 08             	lea    0x8(%ebx),%eax
  80054c:	50                   	push   %eax
  80054d:	e8 2f 09 00 00       	call   800e81 <sys_cputs>
		b->idx = 0;
  800552:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800558:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80055b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80055f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80056d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800574:	00 00 00 
	b.cnt = 0;
  800577:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80057e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	ff 75 08             	pushl  0x8(%ebp)
  800587:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	68 22 05 80 00       	push   $0x800522
  800593:	e8 54 01 00 00       	call   8006ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005a7:	50                   	push   %eax
  8005a8:	e8 d4 08 00 00       	call   800e81 <sys_cputs>

	return b.cnt;
}
  8005ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005be:	50                   	push   %eax
  8005bf:	ff 75 08             	pushl  0x8(%ebp)
  8005c2:	e8 9d ff ff ff       	call   800564 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005c7:	c9                   	leave  
  8005c8:	c3                   	ret    

008005c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	57                   	push   %edi
  8005cd:	56                   	push   %esi
  8005ce:	53                   	push   %ebx
  8005cf:	83 ec 1c             	sub    $0x1c,%esp
  8005d2:	89 c7                	mov    %eax,%edi
  8005d4:	89 d6                	mov    %edx,%esi
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005df:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f0:	39 d3                	cmp    %edx,%ebx
  8005f2:	72 05                	jb     8005f9 <printnum+0x30>
  8005f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005f7:	77 45                	ja     80063e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	ff 75 18             	pushl  0x18(%ebp)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800605:	53                   	push   %ebx
  800606:	ff 75 10             	pushl  0x10(%ebp)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff 75 dc             	pushl  -0x24(%ebp)
  800615:	ff 75 d8             	pushl  -0x28(%ebp)
  800618:	e8 f3 1d 00 00       	call   802410 <__udivdi3>
  80061d:	83 c4 18             	add    $0x18,%esp
  800620:	52                   	push   %edx
  800621:	50                   	push   %eax
  800622:	89 f2                	mov    %esi,%edx
  800624:	89 f8                	mov    %edi,%eax
  800626:	e8 9e ff ff ff       	call   8005c9 <printnum>
  80062b:	83 c4 20             	add    $0x20,%esp
  80062e:	eb 18                	jmp    800648 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	ff 75 18             	pushl  0x18(%ebp)
  800637:	ff d7                	call   *%edi
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb 03                	jmp    800641 <printnum+0x78>
  80063e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f e8                	jg     800630 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	56                   	push   %esi
  80064c:	83 ec 04             	sub    $0x4,%esp
  80064f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800652:	ff 75 e0             	pushl  -0x20(%ebp)
  800655:	ff 75 dc             	pushl  -0x24(%ebp)
  800658:	ff 75 d8             	pushl  -0x28(%ebp)
  80065b:	e8 e0 1e 00 00       	call   802540 <__umoddi3>
  800660:	83 c4 14             	add    $0x14,%esp
  800663:	0f be 80 e5 27 80 00 	movsbl 0x8027e5(%eax),%eax
  80066a:	50                   	push   %eax
  80066b:	ff d7                	call   *%edi
}
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80067b:	83 fa 01             	cmp    $0x1,%edx
  80067e:	7e 0e                	jle    80068e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8d 4a 08             	lea    0x8(%edx),%ecx
  800685:	89 08                	mov    %ecx,(%eax)
  800687:	8b 02                	mov    (%edx),%eax
  800689:	8b 52 04             	mov    0x4(%edx),%edx
  80068c:	eb 22                	jmp    8006b0 <getuint+0x38>
	else if (lflag)
  80068e:	85 d2                	test   %edx,%edx
  800690:	74 10                	je     8006a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800692:	8b 10                	mov    (%eax),%edx
  800694:	8d 4a 04             	lea    0x4(%edx),%ecx
  800697:	89 08                	mov    %ecx,(%eax)
  800699:	8b 02                	mov    (%edx),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a0:	eb 0e                	jmp    8006b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a7:	89 08                	mov    %ecx,(%eax)
  8006a9:	8b 02                	mov    (%edx),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c1:	73 0a                	jae    8006cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8006c3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006c6:	89 08                	mov    %ecx,(%eax)
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	88 02                	mov    %al,(%edx)
}
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 05 00 00 00       	call   8006ec <vprintfmt>
	va_end(ap);
}
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	57                   	push   %edi
  8006f0:	56                   	push   %esi
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 2c             	sub    $0x2c,%esp
  8006f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006fe:	eb 12                	jmp    800712 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800700:	85 c0                	test   %eax,%eax
  800702:	0f 84 89 03 00 00    	je     800a91 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	50                   	push   %eax
  80070d:	ff d6                	call   *%esi
  80070f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800712:	83 c7 01             	add    $0x1,%edi
  800715:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800719:	83 f8 25             	cmp    $0x25,%eax
  80071c:	75 e2                	jne    800700 <vprintfmt+0x14>
  80071e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800722:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800729:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800730:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
  80073c:	eb 07                	jmp    800745 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800741:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8d 47 01             	lea    0x1(%edi),%eax
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074b:	0f b6 07             	movzbl (%edi),%eax
  80074e:	0f b6 c8             	movzbl %al,%ecx
  800751:	83 e8 23             	sub    $0x23,%eax
  800754:	3c 55                	cmp    $0x55,%al
  800756:	0f 87 1a 03 00 00    	ja     800a76 <vprintfmt+0x38a>
  80075c:	0f b6 c0             	movzbl %al,%eax
  80075f:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  800766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800769:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80076d:	eb d6                	jmp    800745 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80077a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80077d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800781:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800784:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800787:	83 fa 09             	cmp    $0x9,%edx
  80078a:	77 39                	ja     8007c5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80078c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078f:	eb e9                	jmp    80077a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 48 04             	lea    0x4(%eax),%ecx
  800797:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007a2:	eb 27                	jmp    8007cb <vprintfmt+0xdf>
  8007a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	0f 49 c8             	cmovns %eax,%ecx
  8007b1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b7:	eb 8c                	jmp    800745 <vprintfmt+0x59>
  8007b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007bc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007c3:	eb 80                	jmp    800745 <vprintfmt+0x59>
  8007c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007cf:	0f 89 70 ff ff ff    	jns    800745 <vprintfmt+0x59>
				width = precision, precision = -1;
  8007d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007e2:	e9 5e ff ff ff       	jmp    800745 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007ed:	e9 53 ff ff ff       	jmp    800745 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	ff 30                	pushl  (%eax)
  800801:	ff d6                	call   *%esi
			break;
  800803:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800806:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800809:	e9 04 ff ff ff       	jmp    800712 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8d 50 04             	lea    0x4(%eax),%edx
  800814:	89 55 14             	mov    %edx,0x14(%ebp)
  800817:	8b 00                	mov    (%eax),%eax
  800819:	99                   	cltd   
  80081a:	31 d0                	xor    %edx,%eax
  80081c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80081e:	83 f8 0f             	cmp    $0xf,%eax
  800821:	7f 0b                	jg     80082e <vprintfmt+0x142>
  800823:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  80082a:	85 d2                	test   %edx,%edx
  80082c:	75 18                	jne    800846 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80082e:	50                   	push   %eax
  80082f:	68 fd 27 80 00       	push   $0x8027fd
  800834:	53                   	push   %ebx
  800835:	56                   	push   %esi
  800836:	e8 94 fe ff ff       	call   8006cf <printfmt>
  80083b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800841:	e9 cc fe ff ff       	jmp    800712 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800846:	52                   	push   %edx
  800847:	68 b5 2b 80 00       	push   $0x802bb5
  80084c:	53                   	push   %ebx
  80084d:	56                   	push   %esi
  80084e:	e8 7c fe ff ff       	call   8006cf <printfmt>
  800853:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800859:	e9 b4 fe ff ff       	jmp    800712 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8d 50 04             	lea    0x4(%eax),%edx
  800864:	89 55 14             	mov    %edx,0x14(%ebp)
  800867:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800869:	85 ff                	test   %edi,%edi
  80086b:	b8 f6 27 80 00       	mov    $0x8027f6,%eax
  800870:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800873:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800877:	0f 8e 94 00 00 00    	jle    800911 <vprintfmt+0x225>
  80087d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800881:	0f 84 98 00 00 00    	je     80091f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	ff 75 d0             	pushl  -0x30(%ebp)
  80088d:	57                   	push   %edi
  80088e:	e8 86 02 00 00       	call   800b19 <strnlen>
  800893:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800896:	29 c1                	sub    %eax,%ecx
  800898:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80089b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80089e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008a5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008a8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008aa:	eb 0f                	jmp    8008bb <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b5:	83 ef 01             	sub    $0x1,%edi
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	85 ff                	test   %edi,%edi
  8008bd:	7f ed                	jg     8008ac <vprintfmt+0x1c0>
  8008bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008c2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cc:	0f 49 c1             	cmovns %ecx,%eax
  8008cf:	29 c1                	sub    %eax,%ecx
  8008d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8008d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008da:	89 cb                	mov    %ecx,%ebx
  8008dc:	eb 4d                	jmp    80092b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008e2:	74 1b                	je     8008ff <vprintfmt+0x213>
  8008e4:	0f be c0             	movsbl %al,%eax
  8008e7:	83 e8 20             	sub    $0x20,%eax
  8008ea:	83 f8 5e             	cmp    $0x5e,%eax
  8008ed:	76 10                	jbe    8008ff <vprintfmt+0x213>
					putch('?', putdat);
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	ff 75 0c             	pushl  0xc(%ebp)
  8008f5:	6a 3f                	push   $0x3f
  8008f7:	ff 55 08             	call   *0x8(%ebp)
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	eb 0d                	jmp    80090c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	52                   	push   %edx
  800906:	ff 55 08             	call   *0x8(%ebp)
  800909:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090c:	83 eb 01             	sub    $0x1,%ebx
  80090f:	eb 1a                	jmp    80092b <vprintfmt+0x23f>
  800911:	89 75 08             	mov    %esi,0x8(%ebp)
  800914:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800917:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80091a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80091d:	eb 0c                	jmp    80092b <vprintfmt+0x23f>
  80091f:	89 75 08             	mov    %esi,0x8(%ebp)
  800922:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800925:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800928:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80092b:	83 c7 01             	add    $0x1,%edi
  80092e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800932:	0f be d0             	movsbl %al,%edx
  800935:	85 d2                	test   %edx,%edx
  800937:	74 23                	je     80095c <vprintfmt+0x270>
  800939:	85 f6                	test   %esi,%esi
  80093b:	78 a1                	js     8008de <vprintfmt+0x1f2>
  80093d:	83 ee 01             	sub    $0x1,%esi
  800940:	79 9c                	jns    8008de <vprintfmt+0x1f2>
  800942:	89 df                	mov    %ebx,%edi
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094a:	eb 18                	jmp    800964 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80094c:	83 ec 08             	sub    $0x8,%esp
  80094f:	53                   	push   %ebx
  800950:	6a 20                	push   $0x20
  800952:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800954:	83 ef 01             	sub    $0x1,%edi
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	eb 08                	jmp    800964 <vprintfmt+0x278>
  80095c:	89 df                	mov    %ebx,%edi
  80095e:	8b 75 08             	mov    0x8(%ebp),%esi
  800961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800964:	85 ff                	test   %edi,%edi
  800966:	7f e4                	jg     80094c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800968:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096b:	e9 a2 fd ff ff       	jmp    800712 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800970:	83 fa 01             	cmp    $0x1,%edx
  800973:	7e 16                	jle    80098b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	8d 50 08             	lea    0x8(%eax),%edx
  80097b:	89 55 14             	mov    %edx,0x14(%ebp)
  80097e:	8b 50 04             	mov    0x4(%eax),%edx
  800981:	8b 00                	mov    (%eax),%eax
  800983:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800986:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800989:	eb 32                	jmp    8009bd <vprintfmt+0x2d1>
	else if (lflag)
  80098b:	85 d2                	test   %edx,%edx
  80098d:	74 18                	je     8009a7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099d:	89 c1                	mov    %eax,%ecx
  80099f:	c1 f9 1f             	sar    $0x1f,%ecx
  8009a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009a5:	eb 16                	jmp    8009bd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8d 50 04             	lea    0x4(%eax),%edx
  8009ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b0:	8b 00                	mov    (%eax),%eax
  8009b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009b5:	89 c1                	mov    %eax,%ecx
  8009b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009cc:	79 74                	jns    800a42 <vprintfmt+0x356>
				putch('-', putdat);
  8009ce:	83 ec 08             	sub    $0x8,%esp
  8009d1:	53                   	push   %ebx
  8009d2:	6a 2d                	push   $0x2d
  8009d4:	ff d6                	call   *%esi
				num = -(long long) num;
  8009d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009dc:	f7 d8                	neg    %eax
  8009de:	83 d2 00             	adc    $0x0,%edx
  8009e1:	f7 da                	neg    %edx
  8009e3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009eb:	eb 55                	jmp    800a42 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f0:	e8 83 fc ff ff       	call   800678 <getuint>
			base = 10;
  8009f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009fa:	eb 46                	jmp    800a42 <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8009fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ff:	e8 74 fc ff ff       	call   800678 <getuint>
			base = 8;
  800a04:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a09:	eb 37                	jmp    800a42 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a0b:	83 ec 08             	sub    $0x8,%esp
  800a0e:	53                   	push   %ebx
  800a0f:	6a 30                	push   $0x30
  800a11:	ff d6                	call   *%esi
			putch('x', putdat);
  800a13:	83 c4 08             	add    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 78                	push   $0x78
  800a19:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1e:	8d 50 04             	lea    0x4(%eax),%edx
  800a21:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a24:	8b 00                	mov    (%eax),%eax
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a2b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a2e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a33:	eb 0d                	jmp    800a42 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a35:	8d 45 14             	lea    0x14(%ebp),%eax
  800a38:	e8 3b fc ff ff       	call   800678 <getuint>
			base = 16;
  800a3d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a42:	83 ec 0c             	sub    $0xc,%esp
  800a45:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a49:	57                   	push   %edi
  800a4a:	ff 75 e0             	pushl  -0x20(%ebp)
  800a4d:	51                   	push   %ecx
  800a4e:	52                   	push   %edx
  800a4f:	50                   	push   %eax
  800a50:	89 da                	mov    %ebx,%edx
  800a52:	89 f0                	mov    %esi,%eax
  800a54:	e8 70 fb ff ff       	call   8005c9 <printnum>
			break;
  800a59:	83 c4 20             	add    $0x20,%esp
  800a5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5f:	e9 ae fc ff ff       	jmp    800712 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	53                   	push   %ebx
  800a68:	51                   	push   %ecx
  800a69:	ff d6                	call   *%esi
			break;
  800a6b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a71:	e9 9c fc ff ff       	jmp    800712 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a76:	83 ec 08             	sub    $0x8,%esp
  800a79:	53                   	push   %ebx
  800a7a:	6a 25                	push   $0x25
  800a7c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a7e:	83 c4 10             	add    $0x10,%esp
  800a81:	eb 03                	jmp    800a86 <vprintfmt+0x39a>
  800a83:	83 ef 01             	sub    $0x1,%edi
  800a86:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a8a:	75 f7                	jne    800a83 <vprintfmt+0x397>
  800a8c:	e9 81 fc ff ff       	jmp    800712 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 18             	sub    $0x18,%esp
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aa8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aaf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ab6:	85 c0                	test   %eax,%eax
  800ab8:	74 26                	je     800ae0 <vsnprintf+0x47>
  800aba:	85 d2                	test   %edx,%edx
  800abc:	7e 22                	jle    800ae0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800abe:	ff 75 14             	pushl  0x14(%ebp)
  800ac1:	ff 75 10             	pushl  0x10(%ebp)
  800ac4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac7:	50                   	push   %eax
  800ac8:	68 b2 06 80 00       	push   $0x8006b2
  800acd:	e8 1a fc ff ff       	call   8006ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	eb 05                	jmp    800ae5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af0:	50                   	push   %eax
  800af1:	ff 75 10             	pushl  0x10(%ebp)
  800af4:	ff 75 0c             	pushl  0xc(%ebp)
  800af7:	ff 75 08             	pushl  0x8(%ebp)
  800afa:	e8 9a ff ff ff       	call   800a99 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    

00800b01 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	eb 03                	jmp    800b11 <strlen+0x10>
		n++;
  800b0e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b11:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b15:	75 f7                	jne    800b0e <strlen+0xd>
		n++;
	return n;
}
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	eb 03                	jmp    800b2c <strnlen+0x13>
		n++;
  800b29:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2c:	39 c2                	cmp    %eax,%edx
  800b2e:	74 08                	je     800b38 <strnlen+0x1f>
  800b30:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b34:	75 f3                	jne    800b29 <strnlen+0x10>
  800b36:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	53                   	push   %ebx
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b44:	89 c2                	mov    %eax,%edx
  800b46:	83 c2 01             	add    $0x1,%edx
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b50:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b53:	84 db                	test   %bl,%bl
  800b55:	75 ef                	jne    800b46 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b57:	5b                   	pop    %ebx
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b61:	53                   	push   %ebx
  800b62:	e8 9a ff ff ff       	call   800b01 <strlen>
  800b67:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b6a:	ff 75 0c             	pushl  0xc(%ebp)
  800b6d:	01 d8                	add    %ebx,%eax
  800b6f:	50                   	push   %eax
  800b70:	e8 c5 ff ff ff       	call   800b3a <strcpy>
	return dst;
}
  800b75:	89 d8                	mov    %ebx,%eax
  800b77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 75 08             	mov    0x8(%ebp),%esi
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b8c:	89 f2                	mov    %esi,%edx
  800b8e:	eb 0f                	jmp    800b9f <strncpy+0x23>
		*dst++ = *src;
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	0f b6 01             	movzbl (%ecx),%eax
  800b96:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b99:	80 39 01             	cmpb   $0x1,(%ecx)
  800b9c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b9f:	39 da                	cmp    %ebx,%edx
  800ba1:	75 ed                	jne    800b90 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ba3:	89 f0                	mov    %esi,%eax
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 10             	mov    0x10(%ebp),%edx
  800bb7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bb9:	85 d2                	test   %edx,%edx
  800bbb:	74 21                	je     800bde <strlcpy+0x35>
  800bbd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc1:	89 f2                	mov    %esi,%edx
  800bc3:	eb 09                	jmp    800bce <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	83 c1 01             	add    $0x1,%ecx
  800bcb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bce:	39 c2                	cmp    %eax,%edx
  800bd0:	74 09                	je     800bdb <strlcpy+0x32>
  800bd2:	0f b6 19             	movzbl (%ecx),%ebx
  800bd5:	84 db                	test   %bl,%bl
  800bd7:	75 ec                	jne    800bc5 <strlcpy+0x1c>
  800bd9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bdb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bde:	29 f0                	sub    %esi,%eax
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bea:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bed:	eb 06                	jmp    800bf5 <strcmp+0x11>
		p++, q++;
  800bef:	83 c1 01             	add    $0x1,%ecx
  800bf2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bf5:	0f b6 01             	movzbl (%ecx),%eax
  800bf8:	84 c0                	test   %al,%al
  800bfa:	74 04                	je     800c00 <strcmp+0x1c>
  800bfc:	3a 02                	cmp    (%edx),%al
  800bfe:	74 ef                	je     800bef <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c00:	0f b6 c0             	movzbl %al,%eax
  800c03:	0f b6 12             	movzbl (%edx),%edx
  800c06:	29 d0                	sub    %edx,%eax
}
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c14:	89 c3                	mov    %eax,%ebx
  800c16:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c19:	eb 06                	jmp    800c21 <strncmp+0x17>
		n--, p++, q++;
  800c1b:	83 c0 01             	add    $0x1,%eax
  800c1e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c21:	39 d8                	cmp    %ebx,%eax
  800c23:	74 15                	je     800c3a <strncmp+0x30>
  800c25:	0f b6 08             	movzbl (%eax),%ecx
  800c28:	84 c9                	test   %cl,%cl
  800c2a:	74 04                	je     800c30 <strncmp+0x26>
  800c2c:	3a 0a                	cmp    (%edx),%cl
  800c2e:	74 eb                	je     800c1b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c30:	0f b6 00             	movzbl (%eax),%eax
  800c33:	0f b6 12             	movzbl (%edx),%edx
  800c36:	29 d0                	sub    %edx,%eax
  800c38:	eb 05                	jmp    800c3f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c4c:	eb 07                	jmp    800c55 <strchr+0x13>
		if (*s == c)
  800c4e:	38 ca                	cmp    %cl,%dl
  800c50:	74 0f                	je     800c61 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	0f b6 10             	movzbl (%eax),%edx
  800c58:	84 d2                	test   %dl,%dl
  800c5a:	75 f2                	jne    800c4e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c6d:	eb 03                	jmp    800c72 <strfind+0xf>
  800c6f:	83 c0 01             	add    $0x1,%eax
  800c72:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c75:	38 ca                	cmp    %cl,%dl
  800c77:	74 04                	je     800c7d <strfind+0x1a>
  800c79:	84 d2                	test   %dl,%dl
  800c7b:	75 f2                	jne    800c6f <strfind+0xc>
			break;
	return (char *) s;
}
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c8b:	85 c9                	test   %ecx,%ecx
  800c8d:	74 36                	je     800cc5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c95:	75 28                	jne    800cbf <memset+0x40>
  800c97:	f6 c1 03             	test   $0x3,%cl
  800c9a:	75 23                	jne    800cbf <memset+0x40>
		c &= 0xFF;
  800c9c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	c1 e3 08             	shl    $0x8,%ebx
  800ca5:	89 d6                	mov    %edx,%esi
  800ca7:	c1 e6 18             	shl    $0x18,%esi
  800caa:	89 d0                	mov    %edx,%eax
  800cac:	c1 e0 10             	shl    $0x10,%eax
  800caf:	09 f0                	or     %esi,%eax
  800cb1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cb3:	89 d8                	mov    %ebx,%eax
  800cb5:	09 d0                	or     %edx,%eax
  800cb7:	c1 e9 02             	shr    $0x2,%ecx
  800cba:	fc                   	cld    
  800cbb:	f3 ab                	rep stos %eax,%es:(%edi)
  800cbd:	eb 06                	jmp    800cc5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc2:	fc                   	cld    
  800cc3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cc5:	89 f8                	mov    %edi,%eax
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cda:	39 c6                	cmp    %eax,%esi
  800cdc:	73 35                	jae    800d13 <memmove+0x47>
  800cde:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce1:	39 d0                	cmp    %edx,%eax
  800ce3:	73 2e                	jae    800d13 <memmove+0x47>
		s += n;
		d += n;
  800ce5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce8:	89 d6                	mov    %edx,%esi
  800cea:	09 fe                	or     %edi,%esi
  800cec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cf2:	75 13                	jne    800d07 <memmove+0x3b>
  800cf4:	f6 c1 03             	test   $0x3,%cl
  800cf7:	75 0e                	jne    800d07 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800cf9:	83 ef 04             	sub    $0x4,%edi
  800cfc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cff:	c1 e9 02             	shr    $0x2,%ecx
  800d02:	fd                   	std    
  800d03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d05:	eb 09                	jmp    800d10 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d07:	83 ef 01             	sub    $0x1,%edi
  800d0a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d0d:	fd                   	std    
  800d0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d10:	fc                   	cld    
  800d11:	eb 1d                	jmp    800d30 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d13:	89 f2                	mov    %esi,%edx
  800d15:	09 c2                	or     %eax,%edx
  800d17:	f6 c2 03             	test   $0x3,%dl
  800d1a:	75 0f                	jne    800d2b <memmove+0x5f>
  800d1c:	f6 c1 03             	test   $0x3,%cl
  800d1f:	75 0a                	jne    800d2b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d21:	c1 e9 02             	shr    $0x2,%ecx
  800d24:	89 c7                	mov    %eax,%edi
  800d26:	fc                   	cld    
  800d27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d29:	eb 05                	jmp    800d30 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d2b:	89 c7                	mov    %eax,%edi
  800d2d:	fc                   	cld    
  800d2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d37:	ff 75 10             	pushl  0x10(%ebp)
  800d3a:	ff 75 0c             	pushl  0xc(%ebp)
  800d3d:	ff 75 08             	pushl  0x8(%ebp)
  800d40:	e8 87 ff ff ff       	call   800ccc <memmove>
}
  800d45:	c9                   	leave  
  800d46:	c3                   	ret    

00800d47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d52:	89 c6                	mov    %eax,%esi
  800d54:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d57:	eb 1a                	jmp    800d73 <memcmp+0x2c>
		if (*s1 != *s2)
  800d59:	0f b6 08             	movzbl (%eax),%ecx
  800d5c:	0f b6 1a             	movzbl (%edx),%ebx
  800d5f:	38 d9                	cmp    %bl,%cl
  800d61:	74 0a                	je     800d6d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d63:	0f b6 c1             	movzbl %cl,%eax
  800d66:	0f b6 db             	movzbl %bl,%ebx
  800d69:	29 d8                	sub    %ebx,%eax
  800d6b:	eb 0f                	jmp    800d7c <memcmp+0x35>
		s1++, s2++;
  800d6d:	83 c0 01             	add    $0x1,%eax
  800d70:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d73:	39 f0                	cmp    %esi,%eax
  800d75:	75 e2                	jne    800d59 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	53                   	push   %ebx
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d87:	89 c1                	mov    %eax,%ecx
  800d89:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d8c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d90:	eb 0a                	jmp    800d9c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d92:	0f b6 10             	movzbl (%eax),%edx
  800d95:	39 da                	cmp    %ebx,%edx
  800d97:	74 07                	je     800da0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d99:	83 c0 01             	add    $0x1,%eax
  800d9c:	39 c8                	cmp    %ecx,%eax
  800d9e:	72 f2                	jb     800d92 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da0:	5b                   	pop    %ebx
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800daf:	eb 03                	jmp    800db4 <strtol+0x11>
		s++;
  800db1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db4:	0f b6 01             	movzbl (%ecx),%eax
  800db7:	3c 20                	cmp    $0x20,%al
  800db9:	74 f6                	je     800db1 <strtol+0xe>
  800dbb:	3c 09                	cmp    $0x9,%al
  800dbd:	74 f2                	je     800db1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dbf:	3c 2b                	cmp    $0x2b,%al
  800dc1:	75 0a                	jne    800dcd <strtol+0x2a>
		s++;
  800dc3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800dcb:	eb 11                	jmp    800dde <strtol+0x3b>
  800dcd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dd2:	3c 2d                	cmp    $0x2d,%al
  800dd4:	75 08                	jne    800dde <strtol+0x3b>
		s++, neg = 1;
  800dd6:	83 c1 01             	add    $0x1,%ecx
  800dd9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dde:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800de4:	75 15                	jne    800dfb <strtol+0x58>
  800de6:	80 39 30             	cmpb   $0x30,(%ecx)
  800de9:	75 10                	jne    800dfb <strtol+0x58>
  800deb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800def:	75 7c                	jne    800e6d <strtol+0xca>
		s += 2, base = 16;
  800df1:	83 c1 02             	add    $0x2,%ecx
  800df4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800df9:	eb 16                	jmp    800e11 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800dfb:	85 db                	test   %ebx,%ebx
  800dfd:	75 12                	jne    800e11 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e04:	80 39 30             	cmpb   $0x30,(%ecx)
  800e07:	75 08                	jne    800e11 <strtol+0x6e>
		s++, base = 8;
  800e09:	83 c1 01             	add    $0x1,%ecx
  800e0c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax
  800e16:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e19:	0f b6 11             	movzbl (%ecx),%edx
  800e1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e1f:	89 f3                	mov    %esi,%ebx
  800e21:	80 fb 09             	cmp    $0x9,%bl
  800e24:	77 08                	ja     800e2e <strtol+0x8b>
			dig = *s - '0';
  800e26:	0f be d2             	movsbl %dl,%edx
  800e29:	83 ea 30             	sub    $0x30,%edx
  800e2c:	eb 22                	jmp    800e50 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e2e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e31:	89 f3                	mov    %esi,%ebx
  800e33:	80 fb 19             	cmp    $0x19,%bl
  800e36:	77 08                	ja     800e40 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e38:	0f be d2             	movsbl %dl,%edx
  800e3b:	83 ea 57             	sub    $0x57,%edx
  800e3e:	eb 10                	jmp    800e50 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e43:	89 f3                	mov    %esi,%ebx
  800e45:	80 fb 19             	cmp    $0x19,%bl
  800e48:	77 16                	ja     800e60 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e4a:	0f be d2             	movsbl %dl,%edx
  800e4d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e50:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e53:	7d 0b                	jge    800e60 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e55:	83 c1 01             	add    $0x1,%ecx
  800e58:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e5c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e5e:	eb b9                	jmp    800e19 <strtol+0x76>

	if (endptr)
  800e60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e64:	74 0d                	je     800e73 <strtol+0xd0>
		*endptr = (char *) s;
  800e66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e69:	89 0e                	mov    %ecx,(%esi)
  800e6b:	eb 06                	jmp    800e73 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e6d:	85 db                	test   %ebx,%ebx
  800e6f:	74 98                	je     800e09 <strtol+0x66>
  800e71:	eb 9e                	jmp    800e11 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	f7 da                	neg    %edx
  800e77:	85 ff                	test   %edi,%edi
  800e79:	0f 45 c2             	cmovne %edx,%eax
}
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	89 c7                	mov    %eax,%edi
  800e96:	89 c6                	mov    %eax,%esi
  800e98:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaa:	b8 01 00 00 00       	mov    $0x1,%eax
  800eaf:	89 d1                	mov    %edx,%ecx
  800eb1:	89 d3                	mov    %edx,%ebx
  800eb3:	89 d7                	mov    %edx,%edi
  800eb5:	89 d6                	mov    %edx,%esi
  800eb7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	89 cb                	mov    %ecx,%ebx
  800ed6:	89 cf                	mov    %ecx,%edi
  800ed8:	89 ce                	mov    %ecx,%esi
  800eda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800edc:	85 c0                	test   %eax,%eax
  800ede:	7e 17                	jle    800ef7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	50                   	push   %eax
  800ee4:	6a 03                	push   $0x3
  800ee6:	68 df 2a 80 00       	push   $0x802adf
  800eeb:	6a 23                	push   $0x23
  800eed:	68 fc 2a 80 00       	push   $0x802afc
  800ef2:	e8 9a 13 00 00       	call   802291 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	57                   	push   %edi
  800f03:	56                   	push   %esi
  800f04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f05:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f0f:	89 d1                	mov    %edx,%ecx
  800f11:	89 d3                	mov    %edx,%ebx
  800f13:	89 d7                	mov    %edx,%edi
  800f15:	89 d6                	mov    %edx,%esi
  800f17:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_yield>:

void
sys_yield(void)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f24:	ba 00 00 00 00       	mov    $0x0,%edx
  800f29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f2e:	89 d1                	mov    %edx,%ecx
  800f30:	89 d3                	mov    %edx,%ebx
  800f32:	89 d7                	mov    %edx,%edi
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	be 00 00 00 00       	mov    $0x0,%esi
  800f4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f59:	89 f7                	mov    %esi,%edi
  800f5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	7e 17                	jle    800f78 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	50                   	push   %eax
  800f65:	6a 04                	push   $0x4
  800f67:	68 df 2a 80 00       	push   $0x802adf
  800f6c:	6a 23                	push   $0x23
  800f6e:	68 fc 2a 80 00       	push   $0x802afc
  800f73:	e8 19 13 00 00       	call   802291 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7b:	5b                   	pop    %ebx
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f89:	b8 05 00 00 00       	mov    $0x5,%eax
  800f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f91:	8b 55 08             	mov    0x8(%ebp),%edx
  800f94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9a:	8b 75 18             	mov    0x18(%ebp),%esi
  800f9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	7e 17                	jle    800fba <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	50                   	push   %eax
  800fa7:	6a 05                	push   $0x5
  800fa9:	68 df 2a 80 00       	push   $0x802adf
  800fae:	6a 23                	push   $0x23
  800fb0:	68 fc 2a 80 00       	push   $0x802afc
  800fb5:	e8 d7 12 00 00       	call   802291 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd0:	b8 06 00 00 00       	mov    $0x6,%eax
  800fd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdb:	89 df                	mov    %ebx,%edi
  800fdd:	89 de                	mov    %ebx,%esi
  800fdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	7e 17                	jle    800ffc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	50                   	push   %eax
  800fe9:	6a 06                	push   $0x6
  800feb:	68 df 2a 80 00       	push   $0x802adf
  800ff0:	6a 23                	push   $0x23
  800ff2:	68 fc 2a 80 00       	push   $0x802afc
  800ff7:	e8 95 12 00 00       	call   802291 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801012:	b8 08 00 00 00       	mov    $0x8,%eax
  801017:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101a:	8b 55 08             	mov    0x8(%ebp),%edx
  80101d:	89 df                	mov    %ebx,%edi
  80101f:	89 de                	mov    %ebx,%esi
  801021:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801023:	85 c0                	test   %eax,%eax
  801025:	7e 17                	jle    80103e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	50                   	push   %eax
  80102b:	6a 08                	push   $0x8
  80102d:	68 df 2a 80 00       	push   $0x802adf
  801032:	6a 23                	push   $0x23
  801034:	68 fc 2a 80 00       	push   $0x802afc
  801039:	e8 53 12 00 00       	call   802291 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80103e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	57                   	push   %edi
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
  80104c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801054:	b8 09 00 00 00       	mov    $0x9,%eax
  801059:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105c:	8b 55 08             	mov    0x8(%ebp),%edx
  80105f:	89 df                	mov    %ebx,%edi
  801061:	89 de                	mov    %ebx,%esi
  801063:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801065:	85 c0                	test   %eax,%eax
  801067:	7e 17                	jle    801080 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	50                   	push   %eax
  80106d:	6a 09                	push   $0x9
  80106f:	68 df 2a 80 00       	push   $0x802adf
  801074:	6a 23                	push   $0x23
  801076:	68 fc 2a 80 00       	push   $0x802afc
  80107b:	e8 11 12 00 00       	call   802291 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	57                   	push   %edi
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
  80108e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801091:	bb 00 00 00 00       	mov    $0x0,%ebx
  801096:	b8 0a 00 00 00       	mov    $0xa,%eax
  80109b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109e:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a1:	89 df                	mov    %ebx,%edi
  8010a3:	89 de                	mov    %ebx,%esi
  8010a5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	7e 17                	jle    8010c2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	50                   	push   %eax
  8010af:	6a 0a                	push   $0xa
  8010b1:	68 df 2a 80 00       	push   $0x802adf
  8010b6:	6a 23                	push   $0x23
  8010b8:	68 fc 2a 80 00       	push   $0x802afc
  8010bd:	e8 cf 11 00 00       	call   802291 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	be 00 00 00 00       	mov    $0x0,%esi
  8010d5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010e6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fb:	b8 0d 00 00 00       	mov    $0xd,%eax
  801100:	8b 55 08             	mov    0x8(%ebp),%edx
  801103:	89 cb                	mov    %ecx,%ebx
  801105:	89 cf                	mov    %ecx,%edi
  801107:	89 ce                	mov    %ecx,%esi
  801109:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	7e 17                	jle    801126 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110f:	83 ec 0c             	sub    $0xc,%esp
  801112:	50                   	push   %eax
  801113:	6a 0d                	push   $0xd
  801115:	68 df 2a 80 00       	push   $0x802adf
  80111a:	6a 23                	push   $0x23
  80111c:	68 fc 2a 80 00       	push   $0x802afc
  801121:	e8 6b 11 00 00       	call   802291 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801134:	ba 00 00 00 00       	mov    $0x0,%edx
  801139:	b8 0e 00 00 00       	mov    $0xe,%eax
  80113e:	89 d1                	mov    %edx,%ecx
  801140:	89 d3                	mov    %edx,%ebx
  801142:	89 d7                	mov    %edx,%edi
  801144:	89 d6                	mov    %edx,%esi
  801146:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801150:	8b 45 08             	mov    0x8(%ebp),%eax
  801153:	05 00 00 00 30       	add    $0x30000000,%eax
  801158:	c1 e8 0c             	shr    $0xc,%eax
}
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801160:	8b 45 08             	mov    0x8(%ebp),%eax
  801163:	05 00 00 00 30       	add    $0x30000000,%eax
  801168:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80116d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117f:	89 c2                	mov    %eax,%edx
  801181:	c1 ea 16             	shr    $0x16,%edx
  801184:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80118b:	f6 c2 01             	test   $0x1,%dl
  80118e:	74 11                	je     8011a1 <fd_alloc+0x2d>
  801190:	89 c2                	mov    %eax,%edx
  801192:	c1 ea 0c             	shr    $0xc,%edx
  801195:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119c:	f6 c2 01             	test   $0x1,%dl
  80119f:	75 09                	jne    8011aa <fd_alloc+0x36>
			*fd_store = fd;
  8011a1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a8:	eb 17                	jmp    8011c1 <fd_alloc+0x4d>
  8011aa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011af:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011b4:	75 c9                	jne    80117f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011b6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011bc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011c9:	83 f8 1f             	cmp    $0x1f,%eax
  8011cc:	77 36                	ja     801204 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ce:	c1 e0 0c             	shl    $0xc,%eax
  8011d1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 16             	shr    $0x16,%edx
  8011db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	74 24                	je     80120b <fd_lookup+0x48>
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 0c             	shr    $0xc,%edx
  8011ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	74 1a                	je     801212 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fb:	89 02                	mov    %eax,(%edx)
	return 0;
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	eb 13                	jmp    801217 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801204:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801209:	eb 0c                	jmp    801217 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801210:	eb 05                	jmp    801217 <fd_lookup+0x54>
  801212:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801222:	ba 88 2b 80 00       	mov    $0x802b88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801227:	eb 13                	jmp    80123c <dev_lookup+0x23>
  801229:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80122c:	39 08                	cmp    %ecx,(%eax)
  80122e:	75 0c                	jne    80123c <dev_lookup+0x23>
			*dev = devtab[i];
  801230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801233:	89 01                	mov    %eax,(%ecx)
			return 0;
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
  80123a:	eb 2e                	jmp    80126a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123c:	8b 02                	mov    (%edx),%eax
  80123e:	85 c0                	test   %eax,%eax
  801240:	75 e7                	jne    801229 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801242:	a1 18 40 80 00       	mov    0x804018,%eax
  801247:	8b 40 48             	mov    0x48(%eax),%eax
  80124a:	83 ec 04             	sub    $0x4,%esp
  80124d:	51                   	push   %ecx
  80124e:	50                   	push   %eax
  80124f:	68 0c 2b 80 00       	push   $0x802b0c
  801254:	e8 5c f3 ff ff       	call   8005b5 <cprintf>
	*dev = 0;
  801259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	56                   	push   %esi
  801270:	53                   	push   %ebx
  801271:	83 ec 10             	sub    $0x10,%esp
  801274:	8b 75 08             	mov    0x8(%ebp),%esi
  801277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801284:	c1 e8 0c             	shr    $0xc,%eax
  801287:	50                   	push   %eax
  801288:	e8 36 ff ff ff       	call   8011c3 <fd_lookup>
  80128d:	83 c4 08             	add    $0x8,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 05                	js     801299 <fd_close+0x2d>
	    || fd != fd2)
  801294:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801297:	74 0c                	je     8012a5 <fd_close+0x39>
		return (must_exist ? r : 0);
  801299:	84 db                	test   %bl,%bl
  80129b:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a0:	0f 44 c2             	cmove  %edx,%eax
  8012a3:	eb 41                	jmp    8012e6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	ff 36                	pushl  (%esi)
  8012ae:	e8 66 ff ff ff       	call   801219 <dev_lookup>
  8012b3:	89 c3                	mov    %eax,%ebx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 1a                	js     8012d6 <fd_close+0x6a>
		if (dev->dev_close)
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	74 0b                	je     8012d6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	56                   	push   %esi
  8012cf:	ff d0                	call   *%eax
  8012d1:	89 c3                	mov    %eax,%ebx
  8012d3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	56                   	push   %esi
  8012da:	6a 00                	push   $0x0
  8012dc:	e8 e1 fc ff ff       	call   800fc2 <sys_page_unmap>
	return r;
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	89 d8                	mov    %ebx,%eax
}
  8012e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 08             	pushl  0x8(%ebp)
  8012fa:	e8 c4 fe ff ff       	call   8011c3 <fd_lookup>
  8012ff:	83 c4 08             	add    $0x8,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 10                	js     801316 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	6a 01                	push   $0x1
  80130b:	ff 75 f4             	pushl  -0xc(%ebp)
  80130e:	e8 59 ff ff ff       	call   80126c <fd_close>
  801313:	83 c4 10             	add    $0x10,%esp
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <close_all>:

void
close_all(void)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80131f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	53                   	push   %ebx
  801328:	e8 c0 ff ff ff       	call   8012ed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132d:	83 c3 01             	add    $0x1,%ebx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	83 fb 20             	cmp    $0x20,%ebx
  801336:	75 ec                	jne    801324 <close_all+0xc>
		close(i);
}
  801338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	57                   	push   %edi
  801341:	56                   	push   %esi
  801342:	53                   	push   %ebx
  801343:	83 ec 2c             	sub    $0x2c,%esp
  801346:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801349:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	ff 75 08             	pushl  0x8(%ebp)
  801350:	e8 6e fe ff ff       	call   8011c3 <fd_lookup>
  801355:	83 c4 08             	add    $0x8,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	0f 88 c1 00 00 00    	js     801421 <dup+0xe4>
		return r;
	close(newfdnum);
  801360:	83 ec 0c             	sub    $0xc,%esp
  801363:	56                   	push   %esi
  801364:	e8 84 ff ff ff       	call   8012ed <close>

	newfd = INDEX2FD(newfdnum);
  801369:	89 f3                	mov    %esi,%ebx
  80136b:	c1 e3 0c             	shl    $0xc,%ebx
  80136e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801374:	83 c4 04             	add    $0x4,%esp
  801377:	ff 75 e4             	pushl  -0x1c(%ebp)
  80137a:	e8 de fd ff ff       	call   80115d <fd2data>
  80137f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801381:	89 1c 24             	mov    %ebx,(%esp)
  801384:	e8 d4 fd ff ff       	call   80115d <fd2data>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80138f:	89 f8                	mov    %edi,%eax
  801391:	c1 e8 16             	shr    $0x16,%eax
  801394:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139b:	a8 01                	test   $0x1,%al
  80139d:	74 37                	je     8013d6 <dup+0x99>
  80139f:	89 f8                	mov    %edi,%eax
  8013a1:	c1 e8 0c             	shr    $0xc,%eax
  8013a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ab:	f6 c2 01             	test   $0x1,%dl
  8013ae:	74 26                	je     8013d6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c3:	6a 00                	push   $0x0
  8013c5:	57                   	push   %edi
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 b3 fb ff ff       	call   800f80 <sys_page_map>
  8013cd:	89 c7                	mov    %eax,%edi
  8013cf:	83 c4 20             	add    $0x20,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 2e                	js     801404 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d9:	89 d0                	mov    %edx,%eax
  8013db:	c1 e8 0c             	shr    $0xc,%eax
  8013de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ed:	50                   	push   %eax
  8013ee:	53                   	push   %ebx
  8013ef:	6a 00                	push   $0x0
  8013f1:	52                   	push   %edx
  8013f2:	6a 00                	push   $0x0
  8013f4:	e8 87 fb ff ff       	call   800f80 <sys_page_map>
  8013f9:	89 c7                	mov    %eax,%edi
  8013fb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013fe:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801400:	85 ff                	test   %edi,%edi
  801402:	79 1d                	jns    801421 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	53                   	push   %ebx
  801408:	6a 00                	push   $0x0
  80140a:	e8 b3 fb ff ff       	call   800fc2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80140f:	83 c4 08             	add    $0x8,%esp
  801412:	ff 75 d4             	pushl  -0x2c(%ebp)
  801415:	6a 00                	push   $0x0
  801417:	e8 a6 fb ff ff       	call   800fc2 <sys_page_unmap>
	return r;
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	89 f8                	mov    %edi,%eax
}
  801421:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5f                   	pop    %edi
  801427:	5d                   	pop    %ebp
  801428:	c3                   	ret    

00801429 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	53                   	push   %ebx
  80142d:	83 ec 14             	sub    $0x14,%esp
  801430:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801433:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	53                   	push   %ebx
  801438:	e8 86 fd ff ff       	call   8011c3 <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	89 c2                	mov    %eax,%edx
  801442:	85 c0                	test   %eax,%eax
  801444:	78 6d                	js     8014b3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801450:	ff 30                	pushl  (%eax)
  801452:	e8 c2 fd ff ff       	call   801219 <dev_lookup>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 4c                	js     8014aa <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801461:	8b 42 08             	mov    0x8(%edx),%eax
  801464:	83 e0 03             	and    $0x3,%eax
  801467:	83 f8 01             	cmp    $0x1,%eax
  80146a:	75 21                	jne    80148d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146c:	a1 18 40 80 00       	mov    0x804018,%eax
  801471:	8b 40 48             	mov    0x48(%eax),%eax
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	53                   	push   %ebx
  801478:	50                   	push   %eax
  801479:	68 4d 2b 80 00       	push   $0x802b4d
  80147e:	e8 32 f1 ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148b:	eb 26                	jmp    8014b3 <read+0x8a>
	}
	if (!dev->dev_read)
  80148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801490:	8b 40 08             	mov    0x8(%eax),%eax
  801493:	85 c0                	test   %eax,%eax
  801495:	74 17                	je     8014ae <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	ff 75 10             	pushl  0x10(%ebp)
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	52                   	push   %edx
  8014a1:	ff d0                	call   *%eax
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	eb 09                	jmp    8014b3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	eb 05                	jmp    8014b3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014b3:	89 d0                	mov    %edx,%eax
  8014b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	57                   	push   %edi
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ce:	eb 21                	jmp    8014f1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	89 f0                	mov    %esi,%eax
  8014d5:	29 d8                	sub    %ebx,%eax
  8014d7:	50                   	push   %eax
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	03 45 0c             	add    0xc(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	57                   	push   %edi
  8014df:	e8 45 ff ff ff       	call   801429 <read>
		if (m < 0)
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 10                	js     8014fb <readn+0x41>
			return m;
		if (m == 0)
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	74 0a                	je     8014f9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ef:	01 c3                	add    %eax,%ebx
  8014f1:	39 f3                	cmp    %esi,%ebx
  8014f3:	72 db                	jb     8014d0 <readn+0x16>
  8014f5:	89 d8                	mov    %ebx,%eax
  8014f7:	eb 02                	jmp    8014fb <readn+0x41>
  8014f9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5f                   	pop    %edi
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 14             	sub    $0x14,%esp
  80150a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	53                   	push   %ebx
  801512:	e8 ac fc ff ff       	call   8011c3 <fd_lookup>
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 68                	js     801588 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	ff 30                	pushl  (%eax)
  80152c:	e8 e8 fc ff ff       	call   801219 <dev_lookup>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 47                	js     80157f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153f:	75 21                	jne    801562 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801541:	a1 18 40 80 00       	mov    0x804018,%eax
  801546:	8b 40 48             	mov    0x48(%eax),%eax
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	53                   	push   %ebx
  80154d:	50                   	push   %eax
  80154e:	68 69 2b 80 00       	push   $0x802b69
  801553:	e8 5d f0 ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801560:	eb 26                	jmp    801588 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	8b 52 0c             	mov    0xc(%edx),%edx
  801568:	85 d2                	test   %edx,%edx
  80156a:	74 17                	je     801583 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	ff 75 10             	pushl  0x10(%ebp)
  801572:	ff 75 0c             	pushl  0xc(%ebp)
  801575:	50                   	push   %eax
  801576:	ff d2                	call   *%edx
  801578:	89 c2                	mov    %eax,%edx
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	eb 09                	jmp    801588 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157f:	89 c2                	mov    %eax,%edx
  801581:	eb 05                	jmp    801588 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801583:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801588:	89 d0                	mov    %edx,%eax
  80158a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <seek>:

int
seek(int fdnum, off_t offset)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801595:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	ff 75 08             	pushl  0x8(%ebp)
  80159c:	e8 22 fc ff ff       	call   8011c3 <fd_lookup>
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 0e                	js     8015b6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ae:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 14             	sub    $0x14,%esp
  8015bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	53                   	push   %ebx
  8015c7:	e8 f7 fb ff ff       	call   8011c3 <fd_lookup>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	89 c2                	mov    %eax,%edx
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 65                	js     80163a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015db:	50                   	push   %eax
  8015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015df:	ff 30                	pushl  (%eax)
  8015e1:	e8 33 fc ff ff       	call   801219 <dev_lookup>
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 44                	js     801631 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f4:	75 21                	jne    801617 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f6:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fb:	8b 40 48             	mov    0x48(%eax),%eax
  8015fe:	83 ec 04             	sub    $0x4,%esp
  801601:	53                   	push   %ebx
  801602:	50                   	push   %eax
  801603:	68 2c 2b 80 00       	push   $0x802b2c
  801608:	e8 a8 ef ff ff       	call   8005b5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801615:	eb 23                	jmp    80163a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161a:	8b 52 18             	mov    0x18(%edx),%edx
  80161d:	85 d2                	test   %edx,%edx
  80161f:	74 14                	je     801635 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	50                   	push   %eax
  801628:	ff d2                	call   *%edx
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb 09                	jmp    80163a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801631:	89 c2                	mov    %eax,%edx
  801633:	eb 05                	jmp    80163a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801635:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80163a:	89 d0                	mov    %edx,%eax
  80163c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	53                   	push   %ebx
  801645:	83 ec 14             	sub    $0x14,%esp
  801648:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	ff 75 08             	pushl  0x8(%ebp)
  801652:	e8 6c fb ff ff       	call   8011c3 <fd_lookup>
  801657:	83 c4 08             	add    $0x8,%esp
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 58                	js     8016b8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801666:	50                   	push   %eax
  801667:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166a:	ff 30                	pushl  (%eax)
  80166c:	e8 a8 fb ff ff       	call   801219 <dev_lookup>
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	78 37                	js     8016af <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167f:	74 32                	je     8016b3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801681:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801684:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168b:	00 00 00 
	stat->st_isdir = 0;
  80168e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801695:	00 00 00 
	stat->st_dev = dev;
  801698:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	53                   	push   %ebx
  8016a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a5:	ff 50 14             	call   *0x14(%eax)
  8016a8:	89 c2                	mov    %eax,%edx
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	eb 09                	jmp    8016b8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	eb 05                	jmp    8016b8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016b8:	89 d0                	mov    %edx,%eax
  8016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	6a 00                	push   $0x0
  8016c9:	ff 75 08             	pushl  0x8(%ebp)
  8016cc:	e8 d6 01 00 00       	call   8018a7 <open>
  8016d1:	89 c3                	mov    %eax,%ebx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 1b                	js     8016f5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	50                   	push   %eax
  8016e1:	e8 5b ff ff ff       	call   801641 <fstat>
  8016e6:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e8:	89 1c 24             	mov    %ebx,(%esp)
  8016eb:	e8 fd fb ff ff       	call   8012ed <close>
	return r;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	89 f0                	mov    %esi,%eax
}
  8016f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	89 c6                	mov    %eax,%esi
  801703:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801705:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  80170c:	75 12                	jne    801720 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80170e:	83 ec 0c             	sub    $0xc,%esp
  801711:	6a 01                	push   $0x1
  801713:	e8 7a 0c 00 00       	call   802392 <ipc_find_env>
  801718:	a3 10 40 80 00       	mov    %eax,0x804010
  80171d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801720:	6a 07                	push   $0x7
  801722:	68 00 50 80 00       	push   $0x805000
  801727:	56                   	push   %esi
  801728:	ff 35 10 40 80 00    	pushl  0x804010
  80172e:	e8 0b 0c 00 00       	call   80233e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801733:	83 c4 0c             	add    $0xc,%esp
  801736:	6a 00                	push   $0x0
  801738:	53                   	push   %ebx
  801739:	6a 00                	push   $0x0
  80173b:	e8 97 0b 00 00       	call   8022d7 <ipc_recv>
}
  801740:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	8b 40 0c             	mov    0xc(%eax),%eax
  801753:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801760:	ba 00 00 00 00       	mov    $0x0,%edx
  801765:	b8 02 00 00 00       	mov    $0x2,%eax
  80176a:	e8 8d ff ff ff       	call   8016fc <fsipc>
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	8b 40 0c             	mov    0xc(%eax),%eax
  80177d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	b8 06 00 00 00       	mov    $0x6,%eax
  80178c:	e8 6b ff ff ff       	call   8016fc <fsipc>
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	53                   	push   %ebx
  801797:	83 ec 04             	sub    $0x4,%esp
  80179a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b2:	e8 45 ff ff ff       	call   8016fc <fsipc>
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 2c                	js     8017e7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	68 00 50 80 00       	push   $0x805000
  8017c3:	53                   	push   %ebx
  8017c4:	e8 71 f3 ff ff       	call   800b3a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 0c             	sub    $0xc,%esp
  8017f2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801801:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801806:	50                   	push   %eax
  801807:	ff 75 0c             	pushl  0xc(%ebp)
  80180a:	68 08 50 80 00       	push   $0x805008
  80180f:	e8 b8 f4 ff ff       	call   800ccc <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	b8 04 00 00 00       	mov    $0x4,%eax
  80181e:	e8 d9 fe ff ff       	call   8016fc <fsipc>

}
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	8b 40 0c             	mov    0xc(%eax),%eax
  801833:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801838:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183e:	ba 00 00 00 00       	mov    $0x0,%edx
  801843:	b8 03 00 00 00       	mov    $0x3,%eax
  801848:	e8 af fe ff ff       	call   8016fc <fsipc>
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	85 c0                	test   %eax,%eax
  801851:	78 4b                	js     80189e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801853:	39 c6                	cmp    %eax,%esi
  801855:	73 16                	jae    80186d <devfile_read+0x48>
  801857:	68 9c 2b 80 00       	push   $0x802b9c
  80185c:	68 a3 2b 80 00       	push   $0x802ba3
  801861:	6a 7c                	push   $0x7c
  801863:	68 b8 2b 80 00       	push   $0x802bb8
  801868:	e8 24 0a 00 00       	call   802291 <_panic>
	assert(r <= PGSIZE);
  80186d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801872:	7e 16                	jle    80188a <devfile_read+0x65>
  801874:	68 c3 2b 80 00       	push   $0x802bc3
  801879:	68 a3 2b 80 00       	push   $0x802ba3
  80187e:	6a 7d                	push   $0x7d
  801880:	68 b8 2b 80 00       	push   $0x802bb8
  801885:	e8 07 0a 00 00       	call   802291 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	50                   	push   %eax
  80188e:	68 00 50 80 00       	push   $0x805000
  801893:	ff 75 0c             	pushl  0xc(%ebp)
  801896:	e8 31 f4 ff ff       	call   800ccc <memmove>
	return r;
  80189b:	83 c4 10             	add    $0x10,%esp
}
  80189e:	89 d8                	mov    %ebx,%eax
  8018a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a3:	5b                   	pop    %ebx
  8018a4:	5e                   	pop    %esi
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 20             	sub    $0x20,%esp
  8018ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b1:	53                   	push   %ebx
  8018b2:	e8 4a f2 ff ff       	call   800b01 <strlen>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018bf:	7f 67                	jg     801928 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c1:	83 ec 0c             	sub    $0xc,%esp
  8018c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c7:	50                   	push   %eax
  8018c8:	e8 a7 f8 ff ff       	call   801174 <fd_alloc>
  8018cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8018d0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 57                	js     80192d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	53                   	push   %ebx
  8018da:	68 00 50 80 00       	push   $0x805000
  8018df:	e8 56 f2 ff ff       	call   800b3a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f4:	e8 03 fe ff ff       	call   8016fc <fsipc>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	79 14                	jns    801916 <open+0x6f>
		fd_close(fd, 0);
  801902:	83 ec 08             	sub    $0x8,%esp
  801905:	6a 00                	push   $0x0
  801907:	ff 75 f4             	pushl  -0xc(%ebp)
  80190a:	e8 5d f9 ff ff       	call   80126c <fd_close>
		return r;
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	89 da                	mov    %ebx,%edx
  801914:	eb 17                	jmp    80192d <open+0x86>
	}

	return fd2num(fd);
  801916:	83 ec 0c             	sub    $0xc,%esp
  801919:	ff 75 f4             	pushl  -0xc(%ebp)
  80191c:	e8 2c f8 ff ff       	call   80114d <fd2num>
  801921:	89 c2                	mov    %eax,%edx
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	eb 05                	jmp    80192d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801928:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80192d:	89 d0                	mov    %edx,%eax
  80192f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193a:	ba 00 00 00 00       	mov    $0x0,%edx
  80193f:	b8 08 00 00 00       	mov    $0x8,%eax
  801944:	e8 b3 fd ff ff       	call   8016fc <fsipc>
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	56                   	push   %esi
  80194f:	53                   	push   %ebx
  801950:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	ff 75 08             	pushl  0x8(%ebp)
  801959:	e8 ff f7 ff ff       	call   80115d <fd2data>
  80195e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801960:	83 c4 08             	add    $0x8,%esp
  801963:	68 cf 2b 80 00       	push   $0x802bcf
  801968:	53                   	push   %ebx
  801969:	e8 cc f1 ff ff       	call   800b3a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196e:	8b 46 04             	mov    0x4(%esi),%eax
  801971:	2b 06                	sub    (%esi),%eax
  801973:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801979:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801980:	00 00 00 
	stat->st_dev = &devpipe;
  801983:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80198a:	30 80 00 
	return 0;
}
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
  801992:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801995:	5b                   	pop    %ebx
  801996:	5e                   	pop    %esi
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	53                   	push   %ebx
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a3:	53                   	push   %ebx
  8019a4:	6a 00                	push   $0x0
  8019a6:	e8 17 f6 ff ff       	call   800fc2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ab:	89 1c 24             	mov    %ebx,(%esp)
  8019ae:	e8 aa f7 ff ff       	call   80115d <fd2data>
  8019b3:	83 c4 08             	add    $0x8,%esp
  8019b6:	50                   	push   %eax
  8019b7:	6a 00                	push   $0x0
  8019b9:	e8 04 f6 ff ff       	call   800fc2 <sys_page_unmap>
}
  8019be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	57                   	push   %edi
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	83 ec 1c             	sub    $0x1c,%esp
  8019cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019cf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d1:	a1 18 40 80 00       	mov    0x804018,%eax
  8019d6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019d9:	83 ec 0c             	sub    $0xc,%esp
  8019dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8019df:	e8 e7 09 00 00       	call   8023cb <pageref>
  8019e4:	89 c3                	mov    %eax,%ebx
  8019e6:	89 3c 24             	mov    %edi,(%esp)
  8019e9:	e8 dd 09 00 00       	call   8023cb <pageref>
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	39 c3                	cmp    %eax,%ebx
  8019f3:	0f 94 c1             	sete   %cl
  8019f6:	0f b6 c9             	movzbl %cl,%ecx
  8019f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019fc:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801a02:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a05:	39 ce                	cmp    %ecx,%esi
  801a07:	74 1b                	je     801a24 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a09:	39 c3                	cmp    %eax,%ebx
  801a0b:	75 c4                	jne    8019d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a0d:	8b 42 58             	mov    0x58(%edx),%eax
  801a10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a13:	50                   	push   %eax
  801a14:	56                   	push   %esi
  801a15:	68 d6 2b 80 00       	push   $0x802bd6
  801a1a:	e8 96 eb ff ff       	call   8005b5 <cprintf>
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	eb ad                	jmp    8019d1 <_pipeisclosed+0xe>
	}
}
  801a24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5f                   	pop    %edi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	57                   	push   %edi
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	83 ec 28             	sub    $0x28,%esp
  801a38:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a3b:	56                   	push   %esi
  801a3c:	e8 1c f7 ff ff       	call   80115d <fd2data>
  801a41:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	bf 00 00 00 00       	mov    $0x0,%edi
  801a4b:	eb 4b                	jmp    801a98 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a4d:	89 da                	mov    %ebx,%edx
  801a4f:	89 f0                	mov    %esi,%eax
  801a51:	e8 6d ff ff ff       	call   8019c3 <_pipeisclosed>
  801a56:	85 c0                	test   %eax,%eax
  801a58:	75 48                	jne    801aa2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a5a:	e8 bf f4 ff ff       	call   800f1e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a5f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a62:	8b 0b                	mov    (%ebx),%ecx
  801a64:	8d 51 20             	lea    0x20(%ecx),%edx
  801a67:	39 d0                	cmp    %edx,%eax
  801a69:	73 e2                	jae    801a4d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a72:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a75:	89 c2                	mov    %eax,%edx
  801a77:	c1 fa 1f             	sar    $0x1f,%edx
  801a7a:	89 d1                	mov    %edx,%ecx
  801a7c:	c1 e9 1b             	shr    $0x1b,%ecx
  801a7f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a82:	83 e2 1f             	and    $0x1f,%edx
  801a85:	29 ca                	sub    %ecx,%edx
  801a87:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a8b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a8f:	83 c0 01             	add    $0x1,%eax
  801a92:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a95:	83 c7 01             	add    $0x1,%edi
  801a98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a9b:	75 c2                	jne    801a5f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa0:	eb 05                	jmp    801aa7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5f                   	pop    %edi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	57                   	push   %edi
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 18             	sub    $0x18,%esp
  801ab8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801abb:	57                   	push   %edi
  801abc:	e8 9c f6 ff ff       	call   80115d <fd2data>
  801ac1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801acb:	eb 3d                	jmp    801b0a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801acd:	85 db                	test   %ebx,%ebx
  801acf:	74 04                	je     801ad5 <devpipe_read+0x26>
				return i;
  801ad1:	89 d8                	mov    %ebx,%eax
  801ad3:	eb 44                	jmp    801b19 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad5:	89 f2                	mov    %esi,%edx
  801ad7:	89 f8                	mov    %edi,%eax
  801ad9:	e8 e5 fe ff ff       	call   8019c3 <_pipeisclosed>
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	75 32                	jne    801b14 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae2:	e8 37 f4 ff ff       	call   800f1e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae7:	8b 06                	mov    (%esi),%eax
  801ae9:	3b 46 04             	cmp    0x4(%esi),%eax
  801aec:	74 df                	je     801acd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aee:	99                   	cltd   
  801aef:	c1 ea 1b             	shr    $0x1b,%edx
  801af2:	01 d0                	add    %edx,%eax
  801af4:	83 e0 1f             	and    $0x1f,%eax
  801af7:	29 d0                	sub    %edx,%eax
  801af9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b01:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b04:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b07:	83 c3 01             	add    $0x1,%ebx
  801b0a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b0d:	75 d8                	jne    801ae7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b0f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b12:	eb 05                	jmp    801b19 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1c:	5b                   	pop    %ebx
  801b1d:	5e                   	pop    %esi
  801b1e:	5f                   	pop    %edi
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    

00801b21 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2c:	50                   	push   %eax
  801b2d:	e8 42 f6 ff ff       	call   801174 <fd_alloc>
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	89 c2                	mov    %eax,%edx
  801b37:	85 c0                	test   %eax,%eax
  801b39:	0f 88 2c 01 00 00    	js     801c6b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3f:	83 ec 04             	sub    $0x4,%esp
  801b42:	68 07 04 00 00       	push   $0x407
  801b47:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4a:	6a 00                	push   $0x0
  801b4c:	e8 ec f3 ff ff       	call   800f3d <sys_page_alloc>
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	89 c2                	mov    %eax,%edx
  801b56:	85 c0                	test   %eax,%eax
  801b58:	0f 88 0d 01 00 00    	js     801c6b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b5e:	83 ec 0c             	sub    $0xc,%esp
  801b61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b64:	50                   	push   %eax
  801b65:	e8 0a f6 ff ff       	call   801174 <fd_alloc>
  801b6a:	89 c3                	mov    %eax,%ebx
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	0f 88 e2 00 00 00    	js     801c59 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b77:	83 ec 04             	sub    $0x4,%esp
  801b7a:	68 07 04 00 00       	push   $0x407
  801b7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b82:	6a 00                	push   $0x0
  801b84:	e8 b4 f3 ff ff       	call   800f3d <sys_page_alloc>
  801b89:	89 c3                	mov    %eax,%ebx
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	0f 88 c3 00 00 00    	js     801c59 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9c:	e8 bc f5 ff ff       	call   80115d <fd2data>
  801ba1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba3:	83 c4 0c             	add    $0xc,%esp
  801ba6:	68 07 04 00 00       	push   $0x407
  801bab:	50                   	push   %eax
  801bac:	6a 00                	push   $0x0
  801bae:	e8 8a f3 ff ff       	call   800f3d <sys_page_alloc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	0f 88 89 00 00 00    	js     801c49 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc0:	83 ec 0c             	sub    $0xc,%esp
  801bc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc6:	e8 92 f5 ff ff       	call   80115d <fd2data>
  801bcb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd2:	50                   	push   %eax
  801bd3:	6a 00                	push   $0x0
  801bd5:	56                   	push   %esi
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 a3 f3 ff ff       	call   800f80 <sys_page_map>
  801bdd:	89 c3                	mov    %eax,%ebx
  801bdf:	83 c4 20             	add    $0x20,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	78 55                	js     801c3b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801be6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bef:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bfb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c04:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c09:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c10:	83 ec 0c             	sub    $0xc,%esp
  801c13:	ff 75 f4             	pushl  -0xc(%ebp)
  801c16:	e8 32 f5 ff ff       	call   80114d <fd2num>
  801c1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c20:	83 c4 04             	add    $0x4,%esp
  801c23:	ff 75 f0             	pushl  -0x10(%ebp)
  801c26:	e8 22 f5 ff ff       	call   80114d <fd2num>
  801c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	ba 00 00 00 00       	mov    $0x0,%edx
  801c39:	eb 30                	jmp    801c6b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c3b:	83 ec 08             	sub    $0x8,%esp
  801c3e:	56                   	push   %esi
  801c3f:	6a 00                	push   $0x0
  801c41:	e8 7c f3 ff ff       	call   800fc2 <sys_page_unmap>
  801c46:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c49:	83 ec 08             	sub    $0x8,%esp
  801c4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 6c f3 ff ff       	call   800fc2 <sys_page_unmap>
  801c56:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c59:	83 ec 08             	sub    $0x8,%esp
  801c5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 5c f3 ff ff       	call   800fc2 <sys_page_unmap>
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c6b:	89 d0                	mov    %edx,%eax
  801c6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c70:	5b                   	pop    %ebx
  801c71:	5e                   	pop    %esi
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    

00801c74 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	ff 75 08             	pushl  0x8(%ebp)
  801c81:	e8 3d f5 ff ff       	call   8011c3 <fd_lookup>
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 18                	js     801ca5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	ff 75 f4             	pushl  -0xc(%ebp)
  801c93:	e8 c5 f4 ff ff       	call   80115d <fd2data>
	return _pipeisclosed(fd, p);
  801c98:	89 c2                	mov    %eax,%edx
  801c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9d:	e8 21 fd ff ff       	call   8019c3 <_pipeisclosed>
  801ca2:	83 c4 10             	add    $0x10,%esp
}
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cad:	68 ee 2b 80 00       	push   $0x802bee
  801cb2:	ff 75 0c             	pushl  0xc(%ebp)
  801cb5:	e8 80 ee ff ff       	call   800b3a <strcpy>
	return 0;
}
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 10             	sub    $0x10,%esp
  801cc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ccb:	53                   	push   %ebx
  801ccc:	e8 fa 06 00 00       	call   8023cb <pageref>
  801cd1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cd4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cd9:	83 f8 01             	cmp    $0x1,%eax
  801cdc:	75 10                	jne    801cee <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cde:	83 ec 0c             	sub    $0xc,%esp
  801ce1:	ff 73 0c             	pushl  0xc(%ebx)
  801ce4:	e8 c0 02 00 00       	call   801fa9 <nsipc_close>
  801ce9:	89 c2                	mov    %eax,%edx
  801ceb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cee:	89 d0                	mov    %edx,%eax
  801cf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cfb:	6a 00                	push   $0x0
  801cfd:	ff 75 10             	pushl  0x10(%ebp)
  801d00:	ff 75 0c             	pushl  0xc(%ebp)
  801d03:	8b 45 08             	mov    0x8(%ebp),%eax
  801d06:	ff 70 0c             	pushl  0xc(%eax)
  801d09:	e8 78 03 00 00       	call   802086 <nsipc_send>
}
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d16:	6a 00                	push   $0x0
  801d18:	ff 75 10             	pushl  0x10(%ebp)
  801d1b:	ff 75 0c             	pushl  0xc(%ebp)
  801d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d21:	ff 70 0c             	pushl  0xc(%eax)
  801d24:	e8 f1 02 00 00       	call   80201a <nsipc_recv>
}
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d31:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d34:	52                   	push   %edx
  801d35:	50                   	push   %eax
  801d36:	e8 88 f4 ff ff       	call   8011c3 <fd_lookup>
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 17                	js     801d59 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d45:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801d4b:	39 08                	cmp    %ecx,(%eax)
  801d4d:	75 05                	jne    801d54 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d4f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d52:	eb 05                	jmp    801d59 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d54:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	56                   	push   %esi
  801d5f:	53                   	push   %ebx
  801d60:	83 ec 1c             	sub    $0x1c,%esp
  801d63:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d68:	50                   	push   %eax
  801d69:	e8 06 f4 ff ff       	call   801174 <fd_alloc>
  801d6e:	89 c3                	mov    %eax,%ebx
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 1b                	js     801d92 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d77:	83 ec 04             	sub    $0x4,%esp
  801d7a:	68 07 04 00 00       	push   $0x407
  801d7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d82:	6a 00                	push   $0x0
  801d84:	e8 b4 f1 ff ff       	call   800f3d <sys_page_alloc>
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	83 c4 10             	add    $0x10,%esp
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	79 10                	jns    801da2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d92:	83 ec 0c             	sub    $0xc,%esp
  801d95:	56                   	push   %esi
  801d96:	e8 0e 02 00 00       	call   801fa9 <nsipc_close>
		return r;
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	89 d8                	mov    %ebx,%eax
  801da0:	eb 24                	jmp    801dc6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801da2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dab:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801db7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	50                   	push   %eax
  801dbe:	e8 8a f3 ff ff       	call   80114d <fd2num>
  801dc3:	83 c4 10             	add    $0x10,%esp
}
  801dc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc9:	5b                   	pop    %ebx
  801dca:	5e                   	pop    %esi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    

00801dcd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd6:	e8 50 ff ff ff       	call   801d2b <fd2sockid>
		return r;
  801ddb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 1f                	js     801e00 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801de1:	83 ec 04             	sub    $0x4,%esp
  801de4:	ff 75 10             	pushl  0x10(%ebp)
  801de7:	ff 75 0c             	pushl  0xc(%ebp)
  801dea:	50                   	push   %eax
  801deb:	e8 12 01 00 00       	call   801f02 <nsipc_accept>
  801df0:	83 c4 10             	add    $0x10,%esp
		return r;
  801df3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 07                	js     801e00 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801df9:	e8 5d ff ff ff       	call   801d5b <alloc_sockfd>
  801dfe:	89 c1                	mov    %eax,%ecx
}
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	c9                   	leave  
  801e03:	c3                   	ret    

00801e04 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0d:	e8 19 ff ff ff       	call   801d2b <fd2sockid>
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 12                	js     801e28 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e16:	83 ec 04             	sub    $0x4,%esp
  801e19:	ff 75 10             	pushl  0x10(%ebp)
  801e1c:	ff 75 0c             	pushl  0xc(%ebp)
  801e1f:	50                   	push   %eax
  801e20:	e8 2d 01 00 00       	call   801f52 <nsipc_bind>
  801e25:	83 c4 10             	add    $0x10,%esp
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <shutdown>:

int
shutdown(int s, int how)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e30:	8b 45 08             	mov    0x8(%ebp),%eax
  801e33:	e8 f3 fe ff ff       	call   801d2b <fd2sockid>
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 0f                	js     801e4b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e3c:	83 ec 08             	sub    $0x8,%esp
  801e3f:	ff 75 0c             	pushl  0xc(%ebp)
  801e42:	50                   	push   %eax
  801e43:	e8 3f 01 00 00       	call   801f87 <nsipc_shutdown>
  801e48:	83 c4 10             	add    $0x10,%esp
}
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    

00801e4d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e53:	8b 45 08             	mov    0x8(%ebp),%eax
  801e56:	e8 d0 fe ff ff       	call   801d2b <fd2sockid>
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 12                	js     801e71 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	ff 75 10             	pushl  0x10(%ebp)
  801e65:	ff 75 0c             	pushl  0xc(%ebp)
  801e68:	50                   	push   %eax
  801e69:	e8 55 01 00 00       	call   801fc3 <nsipc_connect>
  801e6e:	83 c4 10             	add    $0x10,%esp
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <listen>:

int
listen(int s, int backlog)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e79:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7c:	e8 aa fe ff ff       	call   801d2b <fd2sockid>
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 0f                	js     801e94 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e85:	83 ec 08             	sub    $0x8,%esp
  801e88:	ff 75 0c             	pushl  0xc(%ebp)
  801e8b:	50                   	push   %eax
  801e8c:	e8 67 01 00 00       	call   801ff8 <nsipc_listen>
  801e91:	83 c4 10             	add    $0x10,%esp
}
  801e94:	c9                   	leave  
  801e95:	c3                   	ret    

00801e96 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e9c:	ff 75 10             	pushl  0x10(%ebp)
  801e9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ea2:	ff 75 08             	pushl  0x8(%ebp)
  801ea5:	e8 3a 02 00 00       	call   8020e4 <nsipc_socket>
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 05                	js     801eb6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801eb1:	e8 a5 fe ff ff       	call   801d5b <alloc_sockfd>
}
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	53                   	push   %ebx
  801ebc:	83 ec 04             	sub    $0x4,%esp
  801ebf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ec1:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801ec8:	75 12                	jne    801edc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	6a 02                	push   $0x2
  801ecf:	e8 be 04 00 00       	call   802392 <ipc_find_env>
  801ed4:	a3 14 40 80 00       	mov    %eax,0x804014
  801ed9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801edc:	6a 07                	push   $0x7
  801ede:	68 00 60 80 00       	push   $0x806000
  801ee3:	53                   	push   %ebx
  801ee4:	ff 35 14 40 80 00    	pushl  0x804014
  801eea:	e8 4f 04 00 00       	call   80233e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801eef:	83 c4 0c             	add    $0xc,%esp
  801ef2:	6a 00                	push   $0x0
  801ef4:	6a 00                	push   $0x0
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 da 03 00 00       	call   8022d7 <ipc_recv>
}
  801efd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    

00801f02 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	56                   	push   %esi
  801f06:	53                   	push   %ebx
  801f07:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f12:	8b 06                	mov    (%esi),%eax
  801f14:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f19:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1e:	e8 95 ff ff ff       	call   801eb8 <nsipc>
  801f23:	89 c3                	mov    %eax,%ebx
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 20                	js     801f49 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f29:	83 ec 04             	sub    $0x4,%esp
  801f2c:	ff 35 10 60 80 00    	pushl  0x806010
  801f32:	68 00 60 80 00       	push   $0x806000
  801f37:	ff 75 0c             	pushl  0xc(%ebp)
  801f3a:	e8 8d ed ff ff       	call   800ccc <memmove>
		*addrlen = ret->ret_addrlen;
  801f3f:	a1 10 60 80 00       	mov    0x806010,%eax
  801f44:	89 06                	mov    %eax,(%esi)
  801f46:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f49:	89 d8                	mov    %ebx,%eax
  801f4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    

00801f52 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	53                   	push   %ebx
  801f56:	83 ec 08             	sub    $0x8,%esp
  801f59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f64:	53                   	push   %ebx
  801f65:	ff 75 0c             	pushl  0xc(%ebp)
  801f68:	68 04 60 80 00       	push   $0x806004
  801f6d:	e8 5a ed ff ff       	call   800ccc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f72:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f78:	b8 02 00 00 00       	mov    $0x2,%eax
  801f7d:	e8 36 ff ff ff       	call   801eb8 <nsipc>
}
  801f82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f98:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f9d:	b8 03 00 00 00       	mov    $0x3,%eax
  801fa2:	e8 11 ff ff ff       	call   801eb8 <nsipc>
}
  801fa7:	c9                   	leave  
  801fa8:	c3                   	ret    

00801fa9 <nsipc_close>:

int
nsipc_close(int s)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801faf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fb7:	b8 04 00 00 00       	mov    $0x4,%eax
  801fbc:	e8 f7 fe ff ff       	call   801eb8 <nsipc>
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	53                   	push   %ebx
  801fc7:	83 ec 08             	sub    $0x8,%esp
  801fca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fd5:	53                   	push   %ebx
  801fd6:	ff 75 0c             	pushl  0xc(%ebp)
  801fd9:	68 04 60 80 00       	push   $0x806004
  801fde:	e8 e9 ec ff ff       	call   800ccc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fe3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fe9:	b8 05 00 00 00       	mov    $0x5,%eax
  801fee:	e8 c5 fe ff ff       	call   801eb8 <nsipc>
}
  801ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff6:	c9                   	leave  
  801ff7:	c3                   	ret    

00801ff8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  802001:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802006:	8b 45 0c             	mov    0xc(%ebp),%eax
  802009:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80200e:	b8 06 00 00 00       	mov    $0x6,%eax
  802013:	e8 a0 fe ff ff       	call   801eb8 <nsipc>
}
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	56                   	push   %esi
  80201e:	53                   	push   %ebx
  80201f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802022:	8b 45 08             	mov    0x8(%ebp),%eax
  802025:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80202a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802030:	8b 45 14             	mov    0x14(%ebp),%eax
  802033:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802038:	b8 07 00 00 00       	mov    $0x7,%eax
  80203d:	e8 76 fe ff ff       	call   801eb8 <nsipc>
  802042:	89 c3                	mov    %eax,%ebx
  802044:	85 c0                	test   %eax,%eax
  802046:	78 35                	js     80207d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802048:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80204d:	7f 04                	jg     802053 <nsipc_recv+0x39>
  80204f:	39 c6                	cmp    %eax,%esi
  802051:	7d 16                	jge    802069 <nsipc_recv+0x4f>
  802053:	68 fa 2b 80 00       	push   $0x802bfa
  802058:	68 a3 2b 80 00       	push   $0x802ba3
  80205d:	6a 62                	push   $0x62
  80205f:	68 0f 2c 80 00       	push   $0x802c0f
  802064:	e8 28 02 00 00       	call   802291 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802069:	83 ec 04             	sub    $0x4,%esp
  80206c:	50                   	push   %eax
  80206d:	68 00 60 80 00       	push   $0x806000
  802072:	ff 75 0c             	pushl  0xc(%ebp)
  802075:	e8 52 ec ff ff       	call   800ccc <memmove>
  80207a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80207d:	89 d8                	mov    %ebx,%eax
  80207f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	53                   	push   %ebx
  80208a:	83 ec 04             	sub    $0x4,%esp
  80208d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802090:	8b 45 08             	mov    0x8(%ebp),%eax
  802093:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802098:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80209e:	7e 16                	jle    8020b6 <nsipc_send+0x30>
  8020a0:	68 1b 2c 80 00       	push   $0x802c1b
  8020a5:	68 a3 2b 80 00       	push   $0x802ba3
  8020aa:	6a 6d                	push   $0x6d
  8020ac:	68 0f 2c 80 00       	push   $0x802c0f
  8020b1:	e8 db 01 00 00       	call   802291 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020b6:	83 ec 04             	sub    $0x4,%esp
  8020b9:	53                   	push   %ebx
  8020ba:	ff 75 0c             	pushl  0xc(%ebp)
  8020bd:	68 0c 60 80 00       	push   $0x80600c
  8020c2:	e8 05 ec ff ff       	call   800ccc <memmove>
	nsipcbuf.send.req_size = size;
  8020c7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8020d0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020d5:	b8 08 00 00 00       	mov    $0x8,%eax
  8020da:	e8 d9 fd ff ff       	call   801eb8 <nsipc>
}
  8020df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020e2:	c9                   	leave  
  8020e3:	c3                   	ret    

008020e4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8020fd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802102:	b8 09 00 00 00       	mov    $0x9,%eax
  802107:	e8 ac fd ff ff       	call   801eb8 <nsipc>
}
  80210c:	c9                   	leave  
  80210d:	c3                   	ret    

0080210e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802111:	b8 00 00 00 00       	mov    $0x0,%eax
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80211e:	68 27 2c 80 00       	push   $0x802c27
  802123:	ff 75 0c             	pushl  0xc(%ebp)
  802126:	e8 0f ea ff ff       	call   800b3a <strcpy>
	return 0;
}
  80212b:	b8 00 00 00 00       	mov    $0x0,%eax
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80213e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802143:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802149:	eb 2d                	jmp    802178 <devcons_write+0x46>
		m = n - tot;
  80214b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80214e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802150:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802153:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802158:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80215b:	83 ec 04             	sub    $0x4,%esp
  80215e:	53                   	push   %ebx
  80215f:	03 45 0c             	add    0xc(%ebp),%eax
  802162:	50                   	push   %eax
  802163:	57                   	push   %edi
  802164:	e8 63 eb ff ff       	call   800ccc <memmove>
		sys_cputs(buf, m);
  802169:	83 c4 08             	add    $0x8,%esp
  80216c:	53                   	push   %ebx
  80216d:	57                   	push   %edi
  80216e:	e8 0e ed ff ff       	call   800e81 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802173:	01 de                	add    %ebx,%esi
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	89 f0                	mov    %esi,%eax
  80217a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80217d:	72 cc                	jb     80214b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80217f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802182:	5b                   	pop    %ebx
  802183:	5e                   	pop    %esi
  802184:	5f                   	pop    %edi
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    

00802187 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	83 ec 08             	sub    $0x8,%esp
  80218d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802192:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802196:	74 2a                	je     8021c2 <devcons_read+0x3b>
  802198:	eb 05                	jmp    80219f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80219a:	e8 7f ed ff ff       	call   800f1e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80219f:	e8 fb ec ff ff       	call   800e9f <sys_cgetc>
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	74 f2                	je     80219a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	78 16                	js     8021c2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021ac:	83 f8 04             	cmp    $0x4,%eax
  8021af:	74 0c                	je     8021bd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021b4:	88 02                	mov    %al,(%edx)
	return 1;
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	eb 05                	jmp    8021c2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021c2:	c9                   	leave  
  8021c3:	c3                   	ret    

008021c4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021d0:	6a 01                	push   $0x1
  8021d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d5:	50                   	push   %eax
  8021d6:	e8 a6 ec ff ff       	call   800e81 <sys_cputs>
}
  8021db:	83 c4 10             	add    $0x10,%esp
  8021de:	c9                   	leave  
  8021df:	c3                   	ret    

008021e0 <getchar>:

int
getchar(void)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021e6:	6a 01                	push   $0x1
  8021e8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021eb:	50                   	push   %eax
  8021ec:	6a 00                	push   $0x0
  8021ee:	e8 36 f2 ff ff       	call   801429 <read>
	if (r < 0)
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	85 c0                	test   %eax,%eax
  8021f8:	78 0f                	js     802209 <getchar+0x29>
		return r;
	if (r < 1)
  8021fa:	85 c0                	test   %eax,%eax
  8021fc:	7e 06                	jle    802204 <getchar+0x24>
		return -E_EOF;
	return c;
  8021fe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802202:	eb 05                	jmp    802209 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802204:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802209:	c9                   	leave  
  80220a:	c3                   	ret    

0080220b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802214:	50                   	push   %eax
  802215:	ff 75 08             	pushl  0x8(%ebp)
  802218:	e8 a6 ef ff ff       	call   8011c3 <fd_lookup>
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	85 c0                	test   %eax,%eax
  802222:	78 11                	js     802235 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802227:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80222d:	39 10                	cmp    %edx,(%eax)
  80222f:	0f 94 c0             	sete   %al
  802232:	0f b6 c0             	movzbl %al,%eax
}
  802235:	c9                   	leave  
  802236:	c3                   	ret    

00802237 <opencons>:

int
opencons(void)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80223d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802240:	50                   	push   %eax
  802241:	e8 2e ef ff ff       	call   801174 <fd_alloc>
  802246:	83 c4 10             	add    $0x10,%esp
		return r;
  802249:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80224b:	85 c0                	test   %eax,%eax
  80224d:	78 3e                	js     80228d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80224f:	83 ec 04             	sub    $0x4,%esp
  802252:	68 07 04 00 00       	push   $0x407
  802257:	ff 75 f4             	pushl  -0xc(%ebp)
  80225a:	6a 00                	push   $0x0
  80225c:	e8 dc ec ff ff       	call   800f3d <sys_page_alloc>
  802261:	83 c4 10             	add    $0x10,%esp
		return r;
  802264:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802266:	85 c0                	test   %eax,%eax
  802268:	78 23                	js     80228d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80226a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802273:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802278:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80227f:	83 ec 0c             	sub    $0xc,%esp
  802282:	50                   	push   %eax
  802283:	e8 c5 ee ff ff       	call   80114d <fd2num>
  802288:	89 c2                	mov    %eax,%edx
  80228a:	83 c4 10             	add    $0x10,%esp
}
  80228d:	89 d0                	mov    %edx,%eax
  80228f:	c9                   	leave  
  802290:	c3                   	ret    

00802291 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	56                   	push   %esi
  802295:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802296:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802299:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80229f:	e8 5b ec ff ff       	call   800eff <sys_getenvid>
  8022a4:	83 ec 0c             	sub    $0xc,%esp
  8022a7:	ff 75 0c             	pushl  0xc(%ebp)
  8022aa:	ff 75 08             	pushl  0x8(%ebp)
  8022ad:	56                   	push   %esi
  8022ae:	50                   	push   %eax
  8022af:	68 34 2c 80 00       	push   $0x802c34
  8022b4:	e8 fc e2 ff ff       	call   8005b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022b9:	83 c4 18             	add    $0x18,%esp
  8022bc:	53                   	push   %ebx
  8022bd:	ff 75 10             	pushl  0x10(%ebp)
  8022c0:	e8 9f e2 ff ff       	call   800564 <vcprintf>
	cprintf("\n");
  8022c5:	c7 04 24 e7 2b 80 00 	movl   $0x802be7,(%esp)
  8022cc:	e8 e4 e2 ff ff       	call   8005b5 <cprintf>
  8022d1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022d4:	cc                   	int3   
  8022d5:	eb fd                	jmp    8022d4 <_panic+0x43>

008022d7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	56                   	push   %esi
  8022db:	53                   	push   %ebx
  8022dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8022df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8022e5:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8022e7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022ec:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8022ef:	83 ec 0c             	sub    $0xc,%esp
  8022f2:	50                   	push   %eax
  8022f3:	e8 f5 ed ff ff       	call   8010ed <sys_ipc_recv>

	if (from_env_store != NULL)
  8022f8:	83 c4 10             	add    $0x10,%esp
  8022fb:	85 f6                	test   %esi,%esi
  8022fd:	74 14                	je     802313 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8022ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802304:	85 c0                	test   %eax,%eax
  802306:	78 09                	js     802311 <ipc_recv+0x3a>
  802308:	8b 15 18 40 80 00    	mov    0x804018,%edx
  80230e:	8b 52 74             	mov    0x74(%edx),%edx
  802311:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  802313:	85 db                	test   %ebx,%ebx
  802315:	74 14                	je     80232b <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802317:	ba 00 00 00 00       	mov    $0x0,%edx
  80231c:	85 c0                	test   %eax,%eax
  80231e:	78 09                	js     802329 <ipc_recv+0x52>
  802320:	8b 15 18 40 80 00    	mov    0x804018,%edx
  802326:	8b 52 78             	mov    0x78(%edx),%edx
  802329:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80232b:	85 c0                	test   %eax,%eax
  80232d:	78 08                	js     802337 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80232f:	a1 18 40 80 00       	mov    0x804018,%eax
  802334:	8b 40 70             	mov    0x70(%eax),%eax
}
  802337:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80233a:	5b                   	pop    %ebx
  80233b:	5e                   	pop    %esi
  80233c:	5d                   	pop    %ebp
  80233d:	c3                   	ret    

0080233e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 0c             	sub    $0xc,%esp
  802347:	8b 7d 08             	mov    0x8(%ebp),%edi
  80234a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80234d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  802350:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  802352:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802357:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80235a:	ff 75 14             	pushl  0x14(%ebp)
  80235d:	53                   	push   %ebx
  80235e:	56                   	push   %esi
  80235f:	57                   	push   %edi
  802360:	e8 65 ed ff ff       	call   8010ca <sys_ipc_try_send>

		if (err < 0) {
  802365:	83 c4 10             	add    $0x10,%esp
  802368:	85 c0                	test   %eax,%eax
  80236a:	79 1e                	jns    80238a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80236c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80236f:	75 07                	jne    802378 <ipc_send+0x3a>
				sys_yield();
  802371:	e8 a8 eb ff ff       	call   800f1e <sys_yield>
  802376:	eb e2                	jmp    80235a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  802378:	50                   	push   %eax
  802379:	68 58 2c 80 00       	push   $0x802c58
  80237e:	6a 49                	push   $0x49
  802380:	68 65 2c 80 00       	push   $0x802c65
  802385:	e8 07 ff ff ff       	call   802291 <_panic>
		}

	} while (err < 0);

}
  80238a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802398:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80239d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023a0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023a6:	8b 52 50             	mov    0x50(%edx),%edx
  8023a9:	39 ca                	cmp    %ecx,%edx
  8023ab:	75 0d                	jne    8023ba <ipc_find_env+0x28>
			return envs[i].env_id;
  8023ad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023b5:	8b 40 48             	mov    0x48(%eax),%eax
  8023b8:	eb 0f                	jmp    8023c9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023ba:	83 c0 01             	add    $0x1,%eax
  8023bd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023c2:	75 d9                	jne    80239d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    

008023cb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d1:	89 d0                	mov    %edx,%eax
  8023d3:	c1 e8 16             	shr    $0x16,%eax
  8023d6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023dd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e2:	f6 c1 01             	test   $0x1,%cl
  8023e5:	74 1d                	je     802404 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023e7:	c1 ea 0c             	shr    $0xc,%edx
  8023ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023f1:	f6 c2 01             	test   $0x1,%dl
  8023f4:	74 0e                	je     802404 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023f6:	c1 ea 0c             	shr    $0xc,%edx
  8023f9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802400:	ef 
  802401:	0f b7 c0             	movzwl %ax,%eax
}
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    
  802406:	66 90                	xchg   %ax,%ax
  802408:	66 90                	xchg   %ax,%ax
  80240a:	66 90                	xchg   %ax,%ax
  80240c:	66 90                	xchg   %ax,%ax
  80240e:	66 90                	xchg   %ax,%ax

00802410 <__udivdi3>:
  802410:	55                   	push   %ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 1c             	sub    $0x1c,%esp
  802417:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80241b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80241f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802427:	85 f6                	test   %esi,%esi
  802429:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80242d:	89 ca                	mov    %ecx,%edx
  80242f:	89 f8                	mov    %edi,%eax
  802431:	75 3d                	jne    802470 <__udivdi3+0x60>
  802433:	39 cf                	cmp    %ecx,%edi
  802435:	0f 87 c5 00 00 00    	ja     802500 <__udivdi3+0xf0>
  80243b:	85 ff                	test   %edi,%edi
  80243d:	89 fd                	mov    %edi,%ebp
  80243f:	75 0b                	jne    80244c <__udivdi3+0x3c>
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
  802446:	31 d2                	xor    %edx,%edx
  802448:	f7 f7                	div    %edi
  80244a:	89 c5                	mov    %eax,%ebp
  80244c:	89 c8                	mov    %ecx,%eax
  80244e:	31 d2                	xor    %edx,%edx
  802450:	f7 f5                	div    %ebp
  802452:	89 c1                	mov    %eax,%ecx
  802454:	89 d8                	mov    %ebx,%eax
  802456:	89 cf                	mov    %ecx,%edi
  802458:	f7 f5                	div    %ebp
  80245a:	89 c3                	mov    %eax,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	39 ce                	cmp    %ecx,%esi
  802472:	77 74                	ja     8024e8 <__udivdi3+0xd8>
  802474:	0f bd fe             	bsr    %esi,%edi
  802477:	83 f7 1f             	xor    $0x1f,%edi
  80247a:	0f 84 98 00 00 00    	je     802518 <__udivdi3+0x108>
  802480:	bb 20 00 00 00       	mov    $0x20,%ebx
  802485:	89 f9                	mov    %edi,%ecx
  802487:	89 c5                	mov    %eax,%ebp
  802489:	29 fb                	sub    %edi,%ebx
  80248b:	d3 e6                	shl    %cl,%esi
  80248d:	89 d9                	mov    %ebx,%ecx
  80248f:	d3 ed                	shr    %cl,%ebp
  802491:	89 f9                	mov    %edi,%ecx
  802493:	d3 e0                	shl    %cl,%eax
  802495:	09 ee                	or     %ebp,%esi
  802497:	89 d9                	mov    %ebx,%ecx
  802499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249d:	89 d5                	mov    %edx,%ebp
  80249f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024a3:	d3 ed                	shr    %cl,%ebp
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	d3 e2                	shl    %cl,%edx
  8024a9:	89 d9                	mov    %ebx,%ecx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	09 c2                	or     %eax,%edx
  8024af:	89 d0                	mov    %edx,%eax
  8024b1:	89 ea                	mov    %ebp,%edx
  8024b3:	f7 f6                	div    %esi
  8024b5:	89 d5                	mov    %edx,%ebp
  8024b7:	89 c3                	mov    %eax,%ebx
  8024b9:	f7 64 24 0c          	mull   0xc(%esp)
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	72 10                	jb     8024d1 <__udivdi3+0xc1>
  8024c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e6                	shl    %cl,%esi
  8024c9:	39 c6                	cmp    %eax,%esi
  8024cb:	73 07                	jae    8024d4 <__udivdi3+0xc4>
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	75 03                	jne    8024d4 <__udivdi3+0xc4>
  8024d1:	83 eb 01             	sub    $0x1,%ebx
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 d8                	mov    %ebx,%eax
  8024d8:	89 fa                	mov    %edi,%edx
  8024da:	83 c4 1c             	add    $0x1c,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 ff                	xor    %edi,%edi
  8024ea:	31 db                	xor    %ebx,%ebx
  8024ec:	89 d8                	mov    %ebx,%eax
  8024ee:	89 fa                	mov    %edi,%edx
  8024f0:	83 c4 1c             	add    $0x1c,%esp
  8024f3:	5b                   	pop    %ebx
  8024f4:	5e                   	pop    %esi
  8024f5:	5f                   	pop    %edi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
  8024f8:	90                   	nop
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d8                	mov    %ebx,%eax
  802502:	f7 f7                	div    %edi
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 c3                	mov    %eax,%ebx
  802508:	89 d8                	mov    %ebx,%eax
  80250a:	89 fa                	mov    %edi,%edx
  80250c:	83 c4 1c             	add    $0x1c,%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802518:	39 ce                	cmp    %ecx,%esi
  80251a:	72 0c                	jb     802528 <__udivdi3+0x118>
  80251c:	31 db                	xor    %ebx,%ebx
  80251e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802522:	0f 87 34 ff ff ff    	ja     80245c <__udivdi3+0x4c>
  802528:	bb 01 00 00 00       	mov    $0x1,%ebx
  80252d:	e9 2a ff ff ff       	jmp    80245c <__udivdi3+0x4c>
  802532:	66 90                	xchg   %ax,%ax
  802534:	66 90                	xchg   %ax,%ax
  802536:	66 90                	xchg   %ax,%ax
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__umoddi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80254b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80254f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 d2                	test   %edx,%edx
  802559:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80255d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802561:	89 f3                	mov    %esi,%ebx
  802563:	89 3c 24             	mov    %edi,(%esp)
  802566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256a:	75 1c                	jne    802588 <__umoddi3+0x48>
  80256c:	39 f7                	cmp    %esi,%edi
  80256e:	76 50                	jbe    8025c0 <__umoddi3+0x80>
  802570:	89 c8                	mov    %ecx,%eax
  802572:	89 f2                	mov    %esi,%edx
  802574:	f7 f7                	div    %edi
  802576:	89 d0                	mov    %edx,%eax
  802578:	31 d2                	xor    %edx,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	39 f2                	cmp    %esi,%edx
  80258a:	89 d0                	mov    %edx,%eax
  80258c:	77 52                	ja     8025e0 <__umoddi3+0xa0>
  80258e:	0f bd ea             	bsr    %edx,%ebp
  802591:	83 f5 1f             	xor    $0x1f,%ebp
  802594:	75 5a                	jne    8025f0 <__umoddi3+0xb0>
  802596:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80259a:	0f 82 e0 00 00 00    	jb     802680 <__umoddi3+0x140>
  8025a0:	39 0c 24             	cmp    %ecx,(%esp)
  8025a3:	0f 86 d7 00 00 00    	jbe    802680 <__umoddi3+0x140>
  8025a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025b1:	83 c4 1c             	add    $0x1c,%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    
  8025b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	85 ff                	test   %edi,%edi
  8025c2:	89 fd                	mov    %edi,%ebp
  8025c4:	75 0b                	jne    8025d1 <__umoddi3+0x91>
  8025c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	f7 f7                	div    %edi
  8025cf:	89 c5                	mov    %eax,%ebp
  8025d1:	89 f0                	mov    %esi,%eax
  8025d3:	31 d2                	xor    %edx,%edx
  8025d5:	f7 f5                	div    %ebp
  8025d7:	89 c8                	mov    %ecx,%eax
  8025d9:	f7 f5                	div    %ebp
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	eb 99                	jmp    802578 <__umoddi3+0x38>
  8025df:	90                   	nop
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	83 c4 1c             	add    $0x1c,%esp
  8025e7:	5b                   	pop    %ebx
  8025e8:	5e                   	pop    %esi
  8025e9:	5f                   	pop    %edi
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    
  8025ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	8b 34 24             	mov    (%esp),%esi
  8025f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	29 ef                	sub    %ebp,%edi
  8025fc:	d3 e0                	shl    %cl,%eax
  8025fe:	89 f9                	mov    %edi,%ecx
  802600:	89 f2                	mov    %esi,%edx
  802602:	d3 ea                	shr    %cl,%edx
  802604:	89 e9                	mov    %ebp,%ecx
  802606:	09 c2                	or     %eax,%edx
  802608:	89 d8                	mov    %ebx,%eax
  80260a:	89 14 24             	mov    %edx,(%esp)
  80260d:	89 f2                	mov    %esi,%edx
  80260f:	d3 e2                	shl    %cl,%edx
  802611:	89 f9                	mov    %edi,%ecx
  802613:	89 54 24 04          	mov    %edx,0x4(%esp)
  802617:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	89 c6                	mov    %eax,%esi
  802621:	d3 e3                	shl    %cl,%ebx
  802623:	89 f9                	mov    %edi,%ecx
  802625:	89 d0                	mov    %edx,%eax
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	09 d8                	or     %ebx,%eax
  80262d:	89 d3                	mov    %edx,%ebx
  80262f:	89 f2                	mov    %esi,%edx
  802631:	f7 34 24             	divl   (%esp)
  802634:	89 d6                	mov    %edx,%esi
  802636:	d3 e3                	shl    %cl,%ebx
  802638:	f7 64 24 04          	mull   0x4(%esp)
  80263c:	39 d6                	cmp    %edx,%esi
  80263e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802642:	89 d1                	mov    %edx,%ecx
  802644:	89 c3                	mov    %eax,%ebx
  802646:	72 08                	jb     802650 <__umoddi3+0x110>
  802648:	75 11                	jne    80265b <__umoddi3+0x11b>
  80264a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80264e:	73 0b                	jae    80265b <__umoddi3+0x11b>
  802650:	2b 44 24 04          	sub    0x4(%esp),%eax
  802654:	1b 14 24             	sbb    (%esp),%edx
  802657:	89 d1                	mov    %edx,%ecx
  802659:	89 c3                	mov    %eax,%ebx
  80265b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80265f:	29 da                	sub    %ebx,%edx
  802661:	19 ce                	sbb    %ecx,%esi
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 f0                	mov    %esi,%eax
  802667:	d3 e0                	shl    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	d3 ea                	shr    %cl,%edx
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	d3 ee                	shr    %cl,%esi
  802671:	09 d0                	or     %edx,%eax
  802673:	89 f2                	mov    %esi,%edx
  802675:	83 c4 1c             	add    $0x1c,%esp
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    
  80267d:	8d 76 00             	lea    0x0(%esi),%esi
  802680:	29 f9                	sub    %edi,%ecx
  802682:	19 d6                	sbb    %edx,%esi
  802684:	89 74 24 04          	mov    %esi,0x4(%esp)
  802688:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80268c:	e9 18 ff ff ff       	jmp    8025a9 <__umoddi3+0x69>
