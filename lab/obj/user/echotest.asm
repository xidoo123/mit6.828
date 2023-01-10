
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 79 04 00 00       	call   8004aa <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 c0 26 80 00       	push   $0x8026c0
  80003f:	e8 59 05 00 00       	call   80059d <cprintf>
	exit();
  800044:	e8 a7 04 00 00       	call   8004f0 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 58             	sub    $0x58,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  800057:	68 c4 26 80 00       	push   $0x8026c4
  80005c:	e8 3c 05 00 00       	call   80059d <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800061:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  800068:	e8 0b 04 00 00       	call   800478 <inet_addr>
  80006d:	83 c4 0c             	add    $0xc,%esp
  800070:	50                   	push   %eax
  800071:	68 d4 26 80 00       	push   $0x8026d4
  800076:	68 de 26 80 00       	push   $0x8026de
  80007b:	e8 1d 05 00 00       	call   80059d <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	6a 06                	push   $0x6
  800085:	6a 01                	push   $0x1
  800087:	6a 02                	push   $0x2
  800089:	e8 d6 1a 00 00       	call   801b64 <socket>
  80008e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 0a                	jns    8000a2 <umain+0x54>
		die("Failed to create socket");
  800098:	b8 f3 26 80 00       	mov    $0x8026f3,%eax
  80009d:	e8 91 ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	68 0b 27 80 00       	push   $0x80270b
  8000aa:	e8 ee 04 00 00       	call   80059d <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 10                	push   $0x10
  8000b4:	6a 00                	push   $0x0
  8000b6:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b9:	53                   	push   %ebx
  8000ba:	e8 a8 0b 00 00       	call   800c67 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000bf:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000c3:	c7 04 24 d4 26 80 00 	movl   $0x8026d4,(%esp)
  8000ca:	e8 a9 03 00 00       	call   800478 <inet_addr>
  8000cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000d2:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000d9:	e8 81 01 00 00       	call   80025f <htons>
  8000de:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  8000e2:	c7 04 24 1a 27 80 00 	movl   $0x80271a,(%esp)
  8000e9:	e8 af 04 00 00       	call   80059d <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000ee:	83 c4 0c             	add    $0xc,%esp
  8000f1:	6a 10                	push   $0x10
  8000f3:	53                   	push   %ebx
  8000f4:	ff 75 b4             	pushl  -0x4c(%ebp)
  8000f7:	e8 1f 1a 00 00       	call   801b1b <connect>
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 c0                	test   %eax,%eax
  800101:	79 0a                	jns    80010d <umain+0xbf>
		die("Failed to connect with server");
  800103:	b8 37 27 80 00       	mov    $0x802737,%eax
  800108:	e8 26 ff ff ff       	call   800033 <die>

	cprintf("connected to server\n");
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	68 55 27 80 00       	push   $0x802755
  800115:	e8 83 04 00 00       	call   80059d <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 00 30 80 00    	pushl  0x803000
  800123:	e8 c1 09 00 00       	call   800ae9 <strlen>
  800128:	89 c7                	mov    %eax,%edi
  80012a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80012d:	83 c4 0c             	add    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	ff 35 00 30 80 00    	pushl  0x803000
  800137:	ff 75 b4             	pushl  -0x4c(%ebp)
  80013a:	e8 ee 13 00 00       	call   80152d <write>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	39 c7                	cmp    %eax,%edi
  800144:	74 0a                	je     800150 <umain+0x102>
		die("Mismatch in number of sent bytes");
  800146:	b8 84 27 80 00       	mov    $0x802784,%eax
  80014b:	e8 e3 fe ff ff       	call   800033 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	68 6a 27 80 00       	push   $0x80276a
  800158:	e8 40 04 00 00       	call   80059d <cprintf>
	while (received < echolen) {
  80015d:	83 c4 10             	add    $0x10,%esp
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800160:	be 00 00 00 00       	mov    $0x0,%esi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800165:	8d 7d b8             	lea    -0x48(%ebp),%edi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800168:	eb 34                	jmp    80019e <umain+0x150>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80016a:	83 ec 04             	sub    $0x4,%esp
  80016d:	6a 1f                	push   $0x1f
  80016f:	57                   	push   %edi
  800170:	ff 75 b4             	pushl  -0x4c(%ebp)
  800173:	e8 db 12 00 00       	call   801453 <read>
  800178:	89 c3                	mov    %eax,%ebx
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	7f 0a                	jg     80018b <umain+0x13d>
			die("Failed to receive bytes from server");
  800181:	b8 a8 27 80 00       	mov    $0x8027a8,%eax
  800186:	e8 a8 fe ff ff       	call   800033 <die>
		}
		received += bytes;
  80018b:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  80018d:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	57                   	push   %edi
  800196:	e8 02 04 00 00       	call   80059d <cprintf>
  80019b:	83 c4 10             	add    $0x10,%esp
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  80019e:	39 75 b0             	cmp    %esi,-0x50(%ebp)
  8001a1:	77 c7                	ja     80016a <umain+0x11c>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 74 27 80 00       	push   $0x802774
  8001ab:	e8 ed 03 00 00       	call   80059d <cprintf>

	close(sock);
  8001b0:	83 c4 04             	add    $0x4,%esp
  8001b3:	ff 75 b4             	pushl  -0x4c(%ebp)
  8001b6:	e8 5c 11 00 00       	call   801317 <close>
}
  8001bb:	83 c4 10             	add    $0x10,%esp
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001d5:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001d8:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001df:	0f b6 0f             	movzbl (%edi),%ecx
  8001e2:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001e7:	0f b6 d9             	movzbl %cl,%ebx
  8001ea:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8001ed:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8001f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001f3:	66 c1 e8 0b          	shr    $0xb,%ax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001fc:	01 c0                	add    %eax,%eax
  8001fe:	29 c1                	sub    %eax,%ecx
  800200:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800202:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800204:	8d 72 01             	lea    0x1(%edx),%esi
  800207:	0f b6 d2             	movzbl %dl,%edx
  80020a:	83 c0 30             	add    $0x30,%eax
  80020d:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800211:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800213:	84 db                	test   %bl,%bl
  800215:	75 d0                	jne    8001e7 <inet_ntoa+0x21>
  800217:	c6 07 00             	movb   $0x0,(%edi)
  80021a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80021d:	eb 0d                	jmp    80022c <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  80021f:	0f b6 c2             	movzbl %dl,%eax
  800222:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800227:	88 01                	mov    %al,(%ecx)
  800229:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80022c:	83 ea 01             	sub    $0x1,%edx
  80022f:	80 fa ff             	cmp    $0xff,%dl
  800232:	75 eb                	jne    80021f <inet_ntoa+0x59>
  800234:	89 f0                	mov    %esi,%eax
  800236:	0f b6 f0             	movzbl %al,%esi
  800239:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  80023c:	8d 46 01             	lea    0x1(%esi),%eax
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  800245:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80024b:	39 c7                	cmp    %eax,%edi
  80024d:	75 90                	jne    8001df <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  80024f:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800252:	b8 00 40 80 00       	mov    $0x804000,%eax
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800262:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800266:	66 c1 c0 08          	rol    $0x8,%ax
}
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  return htons(n);
  80026f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800273:	66 c1 c0 08          	rol    $0x8,%ax
}
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  80027f:	89 d1                	mov    %edx,%ecx
  800281:	c1 e1 18             	shl    $0x18,%ecx
  800284:	89 d0                	mov    %edx,%eax
  800286:	c1 e8 18             	shr    $0x18,%eax
  800289:	09 c8                	or     %ecx,%eax
  80028b:	89 d1                	mov    %edx,%ecx
  80028d:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800293:	c1 e1 08             	shl    $0x8,%ecx
  800296:	09 c8                	or     %ecx,%eax
  800298:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80029e:	c1 ea 08             	shr    $0x8,%edx
  8002a1:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 20             	sub    $0x20,%esp
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002b1:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002b4:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002b7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002ba:	0f b6 ca             	movzbl %dl,%ecx
  8002bd:	83 e9 30             	sub    $0x30,%ecx
  8002c0:	83 f9 09             	cmp    $0x9,%ecx
  8002c3:	0f 87 94 01 00 00    	ja     80045d <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002c9:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002d0:	83 fa 30             	cmp    $0x30,%edx
  8002d3:	75 2b                	jne    800300 <inet_aton+0x5b>
      c = *++cp;
  8002d5:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002d9:	89 d1                	mov    %edx,%ecx
  8002db:	83 e1 df             	and    $0xffffffdf,%ecx
  8002de:	80 f9 58             	cmp    $0x58,%cl
  8002e1:	74 0f                	je     8002f2 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002e3:	83 c0 01             	add    $0x1,%eax
  8002e6:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8002e9:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8002f0:	eb 0e                	jmp    800300 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8002f2:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8002f6:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8002f9:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800300:	83 c0 01             	add    $0x1,%eax
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	eb 03                	jmp    80030d <inet_aton+0x68>
  80030a:	83 c0 01             	add    $0x1,%eax
  80030d:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800310:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800313:	0f b6 fa             	movzbl %dl,%edi
  800316:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800319:	83 f9 09             	cmp    $0x9,%ecx
  80031c:	77 0d                	ja     80032b <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  80031e:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800322:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800326:	0f be 10             	movsbl (%eax),%edx
  800329:	eb df                	jmp    80030a <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  80032b:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80032f:	75 32                	jne    800363 <inet_aton+0xbe>
  800331:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800334:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800337:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033a:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800340:	83 e9 41             	sub    $0x41,%ecx
  800343:	83 f9 05             	cmp    $0x5,%ecx
  800346:	77 1b                	ja     800363 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800348:	c1 e6 04             	shl    $0x4,%esi
  80034b:	83 c2 0a             	add    $0xa,%edx
  80034e:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800352:	19 c9                	sbb    %ecx,%ecx
  800354:	83 e1 20             	and    $0x20,%ecx
  800357:	83 c1 41             	add    $0x41,%ecx
  80035a:	29 ca                	sub    %ecx,%edx
  80035c:	09 d6                	or     %edx,%esi
        c = *++cp;
  80035e:	0f be 10             	movsbl (%eax),%edx
  800361:	eb a7                	jmp    80030a <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800363:	83 fa 2e             	cmp    $0x2e,%edx
  800366:	75 23                	jne    80038b <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	8d 7d f0             	lea    -0x10(%ebp),%edi
  80036e:	39 f8                	cmp    %edi,%eax
  800370:	0f 84 ee 00 00 00    	je     800464 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800376:	83 c0 04             	add    $0x4,%eax
  800379:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80037c:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  80037f:	8d 43 01             	lea    0x1(%ebx),%eax
  800382:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800386:	e9 2f ff ff ff       	jmp    8002ba <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 25                	je     8003b4 <inet_aton+0x10f>
  80038f:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800397:	83 f9 5f             	cmp    $0x5f,%ecx
  80039a:	0f 87 d0 00 00 00    	ja     800470 <inet_aton+0x1cb>
  8003a0:	83 fa 20             	cmp    $0x20,%edx
  8003a3:	74 0f                	je     8003b4 <inet_aton+0x10f>
  8003a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a8:	83 ea 09             	sub    $0x9,%edx
  8003ab:	83 fa 04             	cmp    $0x4,%edx
  8003ae:	0f 87 bc 00 00 00    	ja     800470 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003ba:	29 c2                	sub    %eax,%edx
  8003bc:	c1 fa 02             	sar    $0x2,%edx
  8003bf:	83 c2 01             	add    $0x1,%edx
  8003c2:	83 fa 02             	cmp    $0x2,%edx
  8003c5:	74 20                	je     8003e7 <inet_aton+0x142>
  8003c7:	83 fa 02             	cmp    $0x2,%edx
  8003ca:	7f 0f                	jg     8003db <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	0f 84 97 00 00 00    	je     800470 <inet_aton+0x1cb>
  8003d9:	eb 67                	jmp    800442 <inet_aton+0x19d>
  8003db:	83 fa 03             	cmp    $0x3,%edx
  8003de:	74 1e                	je     8003fe <inet_aton+0x159>
  8003e0:	83 fa 04             	cmp    $0x4,%edx
  8003e3:	74 38                	je     80041d <inet_aton+0x178>
  8003e5:	eb 5b                	jmp    800442 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8003ec:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8003f2:	77 7c                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8003f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f7:	c1 e0 18             	shl    $0x18,%eax
  8003fa:	09 c6                	or     %eax,%esi
    break;
  8003fc:	eb 44                	jmp    800442 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800403:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800409:	77 65                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	c1 e2 18             	shl    $0x18,%edx
  800411:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800414:	c1 e0 10             	shl    $0x10,%eax
  800417:	09 d0                	or     %edx,%eax
  800419:	09 c6                	or     %eax,%esi
    break;
  80041b:	eb 25                	jmp    800442 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800422:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800428:	77 46                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80042a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042d:	c1 e2 18             	shl    $0x18,%edx
  800430:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800433:	c1 e0 10             	shl    $0x10,%eax
  800436:	09 c2                	or     %eax,%edx
  800438:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80043b:	c1 e0 08             	shl    $0x8,%eax
  80043e:	09 d0                	or     %edx,%eax
  800440:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800442:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800446:	74 23                	je     80046b <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800448:	56                   	push   %esi
  800449:	e8 2b fe ff ff       	call   800279 <htonl>
  80044e:	83 c4 04             	add    $0x4,%esp
  800451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800454:	89 03                	mov    %eax,(%ebx)
  return (1);
  800456:	b8 01 00 00 00       	mov    $0x1,%eax
  80045b:	eb 13                	jmp    800470 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	eb 0c                	jmp    800470 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800464:	b8 00 00 00 00       	mov    $0x0,%eax
  800469:	eb 05                	jmp    800470 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80046b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800473:	5b                   	pop    %ebx
  800474:	5e                   	pop    %esi
  800475:	5f                   	pop    %edi
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    

00800478 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80047e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800481:	50                   	push   %eax
  800482:	ff 75 08             	pushl  0x8(%ebp)
  800485:	e8 1b fe ff ff       	call   8002a5 <inet_aton>
  80048a:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80048d:	85 c0                	test   %eax,%eax
  80048f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800494:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    

0080049a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80049d:	ff 75 08             	pushl  0x8(%ebp)
  8004a0:	e8 d4 fd ff ff       	call   800279 <htonl>
  8004a5:	83 c4 04             	add    $0x4,%esp
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	56                   	push   %esi
  8004ae:	53                   	push   %ebx
  8004af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8004b5:	e8 2d 0a 00 00       	call   800ee7 <sys_getenvid>
  8004ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004c7:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004cc:	85 db                	test   %ebx,%ebx
  8004ce:	7e 07                	jle    8004d7 <libmain+0x2d>
		binaryname = argv[0];
  8004d0:	8b 06                	mov    (%esi),%eax
  8004d2:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
  8004dc:	e8 6d fb ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  8004e1:	e8 0a 00 00 00       	call   8004f0 <exit>
}
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ec:	5b                   	pop    %ebx
  8004ed:	5e                   	pop    %esi
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004f6:	e8 47 0e 00 00       	call   801342 <close_all>
	sys_env_destroy(0);
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	6a 00                	push   $0x0
  800500:	e8 a1 09 00 00       	call   800ea6 <sys_env_destroy>
}
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	c9                   	leave  
  800509:	c3                   	ret    

0080050a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	53                   	push   %ebx
  80050e:	83 ec 04             	sub    $0x4,%esp
  800511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800514:	8b 13                	mov    (%ebx),%edx
  800516:	8d 42 01             	lea    0x1(%edx),%eax
  800519:	89 03                	mov    %eax,(%ebx)
  80051b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80051e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800522:	3d ff 00 00 00       	cmp    $0xff,%eax
  800527:	75 1a                	jne    800543 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	68 ff 00 00 00       	push   $0xff
  800531:	8d 43 08             	lea    0x8(%ebx),%eax
  800534:	50                   	push   %eax
  800535:	e8 2f 09 00 00       	call   800e69 <sys_cputs>
		b->idx = 0;
  80053a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800540:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800543:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800555:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80055c:	00 00 00 
	b.cnt = 0;
  80055f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800566:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800569:	ff 75 0c             	pushl  0xc(%ebp)
  80056c:	ff 75 08             	pushl  0x8(%ebp)
  80056f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800575:	50                   	push   %eax
  800576:	68 0a 05 80 00       	push   $0x80050a
  80057b:	e8 54 01 00 00       	call   8006d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800580:	83 c4 08             	add    $0x8,%esp
  800583:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800589:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80058f:	50                   	push   %eax
  800590:	e8 d4 08 00 00       	call   800e69 <sys_cputs>

	return b.cnt;
}
  800595:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80059b:	c9                   	leave  
  80059c:	c3                   	ret    

0080059d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
  8005a0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005a6:	50                   	push   %eax
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 9d ff ff ff       	call   80054c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	57                   	push   %edi
  8005b5:	56                   	push   %esi
  8005b6:	53                   	push   %ebx
  8005b7:	83 ec 1c             	sub    $0x1c,%esp
  8005ba:	89 c7                	mov    %eax,%edi
  8005bc:	89 d6                	mov    %edx,%esi
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005d5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005d8:	39 d3                	cmp    %edx,%ebx
  8005da:	72 05                	jb     8005e1 <printnum+0x30>
  8005dc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005df:	77 45                	ja     800626 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005e1:	83 ec 0c             	sub    $0xc,%esp
  8005e4:	ff 75 18             	pushl  0x18(%ebp)
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005ed:	53                   	push   %ebx
  8005ee:	ff 75 10             	pushl  0x10(%ebp)
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8005fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800600:	e8 2b 1e 00 00       	call   802430 <__udivdi3>
  800605:	83 c4 18             	add    $0x18,%esp
  800608:	52                   	push   %edx
  800609:	50                   	push   %eax
  80060a:	89 f2                	mov    %esi,%edx
  80060c:	89 f8                	mov    %edi,%eax
  80060e:	e8 9e ff ff ff       	call   8005b1 <printnum>
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	eb 18                	jmp    800630 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	56                   	push   %esi
  80061c:	ff 75 18             	pushl  0x18(%ebp)
  80061f:	ff d7                	call   *%edi
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	eb 03                	jmp    800629 <printnum+0x78>
  800626:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800629:	83 eb 01             	sub    $0x1,%ebx
  80062c:	85 db                	test   %ebx,%ebx
  80062e:	7f e8                	jg     800618 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	83 ec 04             	sub    $0x4,%esp
  800637:	ff 75 e4             	pushl  -0x1c(%ebp)
  80063a:	ff 75 e0             	pushl  -0x20(%ebp)
  80063d:	ff 75 dc             	pushl  -0x24(%ebp)
  800640:	ff 75 d8             	pushl  -0x28(%ebp)
  800643:	e8 18 1f 00 00       	call   802560 <__umoddi3>
  800648:	83 c4 14             	add    $0x14,%esp
  80064b:	0f be 80 d6 27 80 00 	movsbl 0x8027d6(%eax),%eax
  800652:	50                   	push   %eax
  800653:	ff d7                	call   *%edi
}
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065b:	5b                   	pop    %ebx
  80065c:	5e                   	pop    %esi
  80065d:	5f                   	pop    %edi
  80065e:	5d                   	pop    %ebp
  80065f:	c3                   	ret    

00800660 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800663:	83 fa 01             	cmp    $0x1,%edx
  800666:	7e 0e                	jle    800676 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80066d:	89 08                	mov    %ecx,(%eax)
  80066f:	8b 02                	mov    (%edx),%eax
  800671:	8b 52 04             	mov    0x4(%edx),%edx
  800674:	eb 22                	jmp    800698 <getuint+0x38>
	else if (lflag)
  800676:	85 d2                	test   %edx,%edx
  800678:	74 10                	je     80068a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80067f:	89 08                	mov    %ecx,(%eax)
  800681:	8b 02                	mov    (%edx),%eax
  800683:	ba 00 00 00 00       	mov    $0x0,%edx
  800688:	eb 0e                	jmp    800698 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80068f:	89 08                	mov    %ecx,(%eax)
  800691:	8b 02                	mov    (%edx),%eax
  800693:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006a4:	8b 10                	mov    (%eax),%edx
  8006a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006a9:	73 0a                	jae    8006b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ae:	89 08                	mov    %ecx,(%eax)
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	88 02                	mov    %al,(%edx)
}
  8006b5:	5d                   	pop    %ebp
  8006b6:	c3                   	ret    

008006b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006c0:	50                   	push   %eax
  8006c1:	ff 75 10             	pushl  0x10(%ebp)
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	ff 75 08             	pushl  0x8(%ebp)
  8006ca:	e8 05 00 00 00       	call   8006d4 <vprintfmt>
	va_end(ap);
}
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	57                   	push   %edi
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	83 ec 2c             	sub    $0x2c,%esp
  8006dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006e6:	eb 12                	jmp    8006fa <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	0f 84 89 03 00 00    	je     800a79 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	53                   	push   %ebx
  8006f4:	50                   	push   %eax
  8006f5:	ff d6                	call   *%esi
  8006f7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006fa:	83 c7 01             	add    $0x1,%edi
  8006fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800701:	83 f8 25             	cmp    $0x25,%eax
  800704:	75 e2                	jne    8006e8 <vprintfmt+0x14>
  800706:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80070a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800711:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800718:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80071f:	ba 00 00 00 00       	mov    $0x0,%edx
  800724:	eb 07                	jmp    80072d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800729:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	8d 47 01             	lea    0x1(%edi),%eax
  800730:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800733:	0f b6 07             	movzbl (%edi),%eax
  800736:	0f b6 c8             	movzbl %al,%ecx
  800739:	83 e8 23             	sub    $0x23,%eax
  80073c:	3c 55                	cmp    $0x55,%al
  80073e:	0f 87 1a 03 00 00    	ja     800a5e <vprintfmt+0x38a>
  800744:	0f b6 c0             	movzbl %al,%eax
  800747:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  80074e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800751:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800755:	eb d6                	jmp    80072d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
  80075f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800762:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800765:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800769:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80076c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80076f:	83 fa 09             	cmp    $0x9,%edx
  800772:	77 39                	ja     8007ad <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800774:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800777:	eb e9                	jmp    800762 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8d 48 04             	lea    0x4(%eax),%ecx
  80077f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800782:	8b 00                	mov    (%eax),%eax
  800784:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80078a:	eb 27                	jmp    8007b3 <vprintfmt+0xdf>
  80078c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078f:	85 c0                	test   %eax,%eax
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	0f 49 c8             	cmovns %eax,%ecx
  800799:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079f:	eb 8c                	jmp    80072d <vprintfmt+0x59>
  8007a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007ab:	eb 80                	jmp    80072d <vprintfmt+0x59>
  8007ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007b7:	0f 89 70 ff ff ff    	jns    80072d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ca:	e9 5e ff ff ff       	jmp    80072d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007cf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007d5:	e9 53 ff ff ff       	jmp    80072d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 50 04             	lea    0x4(%eax),%edx
  8007e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	ff 30                	pushl  (%eax)
  8007e9:	ff d6                	call   *%esi
			break;
  8007eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007f1:	e9 04 ff ff ff       	jmp    8006fa <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 04             	lea    0x4(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	99                   	cltd   
  800802:	31 d0                	xor    %edx,%eax
  800804:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800806:	83 f8 0f             	cmp    $0xf,%eax
  800809:	7f 0b                	jg     800816 <vprintfmt+0x142>
  80080b:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  800812:	85 d2                	test   %edx,%edx
  800814:	75 18                	jne    80082e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800816:	50                   	push   %eax
  800817:	68 ee 27 80 00       	push   $0x8027ee
  80081c:	53                   	push   %ebx
  80081d:	56                   	push   %esi
  80081e:	e8 94 fe ff ff       	call   8006b7 <printfmt>
  800823:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800829:	e9 cc fe ff ff       	jmp    8006fa <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80082e:	52                   	push   %edx
  80082f:	68 b5 2b 80 00       	push   $0x802bb5
  800834:	53                   	push   %ebx
  800835:	56                   	push   %esi
  800836:	e8 7c fe ff ff       	call   8006b7 <printfmt>
  80083b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800841:	e9 b4 fe ff ff       	jmp    8006fa <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8d 50 04             	lea    0x4(%eax),%edx
  80084c:	89 55 14             	mov    %edx,0x14(%ebp)
  80084f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800851:	85 ff                	test   %edi,%edi
  800853:	b8 e7 27 80 00       	mov    $0x8027e7,%eax
  800858:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80085b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80085f:	0f 8e 94 00 00 00    	jle    8008f9 <vprintfmt+0x225>
  800865:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800869:	0f 84 98 00 00 00    	je     800907 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	ff 75 d0             	pushl  -0x30(%ebp)
  800875:	57                   	push   %edi
  800876:	e8 86 02 00 00       	call   800b01 <strnlen>
  80087b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80087e:	29 c1                	sub    %eax,%ecx
  800880:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800883:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800886:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80088a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80088d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800890:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800892:	eb 0f                	jmp    8008a3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	53                   	push   %ebx
  800898:	ff 75 e0             	pushl  -0x20(%ebp)
  80089b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089d:	83 ef 01             	sub    $0x1,%edi
  8008a0:	83 c4 10             	add    $0x10,%esp
  8008a3:	85 ff                	test   %edi,%edi
  8008a5:	7f ed                	jg     800894 <vprintfmt+0x1c0>
  8008a7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008aa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008ad:	85 c9                	test   %ecx,%ecx
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b4:	0f 49 c1             	cmovns %ecx,%eax
  8008b7:	29 c1                	sub    %eax,%ecx
  8008b9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008bc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008bf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008c2:	89 cb                	mov    %ecx,%ebx
  8008c4:	eb 4d                	jmp    800913 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008c6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ca:	74 1b                	je     8008e7 <vprintfmt+0x213>
  8008cc:	0f be c0             	movsbl %al,%eax
  8008cf:	83 e8 20             	sub    $0x20,%eax
  8008d2:	83 f8 5e             	cmp    $0x5e,%eax
  8008d5:	76 10                	jbe    8008e7 <vprintfmt+0x213>
					putch('?', putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	ff 75 0c             	pushl  0xc(%ebp)
  8008dd:	6a 3f                	push   $0x3f
  8008df:	ff 55 08             	call   *0x8(%ebp)
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 0d                	jmp    8008f4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	ff 75 0c             	pushl  0xc(%ebp)
  8008ed:	52                   	push   %edx
  8008ee:	ff 55 08             	call   *0x8(%ebp)
  8008f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f4:	83 eb 01             	sub    $0x1,%ebx
  8008f7:	eb 1a                	jmp    800913 <vprintfmt+0x23f>
  8008f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800902:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800905:	eb 0c                	jmp    800913 <vprintfmt+0x23f>
  800907:	89 75 08             	mov    %esi,0x8(%ebp)
  80090a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80090d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800910:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800913:	83 c7 01             	add    $0x1,%edi
  800916:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80091a:	0f be d0             	movsbl %al,%edx
  80091d:	85 d2                	test   %edx,%edx
  80091f:	74 23                	je     800944 <vprintfmt+0x270>
  800921:	85 f6                	test   %esi,%esi
  800923:	78 a1                	js     8008c6 <vprintfmt+0x1f2>
  800925:	83 ee 01             	sub    $0x1,%esi
  800928:	79 9c                	jns    8008c6 <vprintfmt+0x1f2>
  80092a:	89 df                	mov    %ebx,%edi
  80092c:	8b 75 08             	mov    0x8(%ebp),%esi
  80092f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800932:	eb 18                	jmp    80094c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	53                   	push   %ebx
  800938:	6a 20                	push   $0x20
  80093a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80093c:	83 ef 01             	sub    $0x1,%edi
  80093f:	83 c4 10             	add    $0x10,%esp
  800942:	eb 08                	jmp    80094c <vprintfmt+0x278>
  800944:	89 df                	mov    %ebx,%edi
  800946:	8b 75 08             	mov    0x8(%ebp),%esi
  800949:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094c:	85 ff                	test   %edi,%edi
  80094e:	7f e4                	jg     800934 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800950:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800953:	e9 a2 fd ff ff       	jmp    8006fa <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800958:	83 fa 01             	cmp    $0x1,%edx
  80095b:	7e 16                	jle    800973 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80095d:	8b 45 14             	mov    0x14(%ebp),%eax
  800960:	8d 50 08             	lea    0x8(%eax),%edx
  800963:	89 55 14             	mov    %edx,0x14(%ebp)
  800966:	8b 50 04             	mov    0x4(%eax),%edx
  800969:	8b 00                	mov    (%eax),%eax
  80096b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80096e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800971:	eb 32                	jmp    8009a5 <vprintfmt+0x2d1>
	else if (lflag)
  800973:	85 d2                	test   %edx,%edx
  800975:	74 18                	je     80098f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8d 50 04             	lea    0x4(%eax),%edx
  80097d:	89 55 14             	mov    %edx,0x14(%ebp)
  800980:	8b 00                	mov    (%eax),%eax
  800982:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800985:	89 c1                	mov    %eax,%ecx
  800987:	c1 f9 1f             	sar    $0x1f,%ecx
  80098a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80098d:	eb 16                	jmp    8009a5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 50 04             	lea    0x4(%eax),%edx
  800995:	89 55 14             	mov    %edx,0x14(%ebp)
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099d:	89 c1                	mov    %eax,%ecx
  80099f:	c1 f9 1f             	sar    $0x1f,%ecx
  8009a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b4:	79 74                	jns    800a2a <vprintfmt+0x356>
				putch('-', putdat);
  8009b6:	83 ec 08             	sub    $0x8,%esp
  8009b9:	53                   	push   %ebx
  8009ba:	6a 2d                	push   $0x2d
  8009bc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009c4:	f7 d8                	neg    %eax
  8009c6:	83 d2 00             	adc    $0x0,%edx
  8009c9:	f7 da                	neg    %edx
  8009cb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009d3:	eb 55                	jmp    800a2a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d8:	e8 83 fc ff ff       	call   800660 <getuint>
			base = 10;
  8009dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8009e2:	eb 46                	jmp    800a2a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8009e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e7:	e8 74 fc ff ff       	call   800660 <getuint>
			base = 8;
  8009ec:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8009f1:	eb 37                	jmp    800a2a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	53                   	push   %ebx
  8009f7:	6a 30                	push   $0x30
  8009f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8009fb:	83 c4 08             	add    $0x8,%esp
  8009fe:	53                   	push   %ebx
  8009ff:	6a 78                	push   $0x78
  800a01:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a03:	8b 45 14             	mov    0x14(%ebp),%eax
  800a06:	8d 50 04             	lea    0x4(%eax),%edx
  800a09:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a0c:	8b 00                	mov    (%eax),%eax
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a13:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a16:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a1b:	eb 0d                	jmp    800a2a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a1d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a20:	e8 3b fc ff ff       	call   800660 <getuint>
			base = 16;
  800a25:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a2a:	83 ec 0c             	sub    $0xc,%esp
  800a2d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a31:	57                   	push   %edi
  800a32:	ff 75 e0             	pushl  -0x20(%ebp)
  800a35:	51                   	push   %ecx
  800a36:	52                   	push   %edx
  800a37:	50                   	push   %eax
  800a38:	89 da                	mov    %ebx,%edx
  800a3a:	89 f0                	mov    %esi,%eax
  800a3c:	e8 70 fb ff ff       	call   8005b1 <printnum>
			break;
  800a41:	83 c4 20             	add    $0x20,%esp
  800a44:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a47:	e9 ae fc ff ff       	jmp    8006fa <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	53                   	push   %ebx
  800a50:	51                   	push   %ecx
  800a51:	ff d6                	call   *%esi
			break;
  800a53:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a59:	e9 9c fc ff ff       	jmp    8006fa <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a5e:	83 ec 08             	sub    $0x8,%esp
  800a61:	53                   	push   %ebx
  800a62:	6a 25                	push   $0x25
  800a64:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a66:	83 c4 10             	add    $0x10,%esp
  800a69:	eb 03                	jmp    800a6e <vprintfmt+0x39a>
  800a6b:	83 ef 01             	sub    $0x1,%edi
  800a6e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a72:	75 f7                	jne    800a6b <vprintfmt+0x397>
  800a74:	e9 81 fc ff ff       	jmp    8006fa <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 18             	sub    $0x18,%esp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a90:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a94:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	74 26                	je     800ac8 <vsnprintf+0x47>
  800aa2:	85 d2                	test   %edx,%edx
  800aa4:	7e 22                	jle    800ac8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aa6:	ff 75 14             	pushl  0x14(%ebp)
  800aa9:	ff 75 10             	pushl  0x10(%ebp)
  800aac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aaf:	50                   	push   %eax
  800ab0:	68 9a 06 80 00       	push   $0x80069a
  800ab5:	e8 1a fc ff ff       	call   8006d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800aba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800abd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	eb 05                	jmp    800acd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ac8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ad5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ad8:	50                   	push   %eax
  800ad9:	ff 75 10             	pushl  0x10(%ebp)
  800adc:	ff 75 0c             	pushl  0xc(%ebp)
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	e8 9a ff ff ff       	call   800a81 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	eb 03                	jmp    800af9 <strlen+0x10>
		n++;
  800af6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800af9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800afd:	75 f7                	jne    800af6 <strlen+0xd>
		n++;
	return n;
}
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	eb 03                	jmp    800b14 <strnlen+0x13>
		n++;
  800b11:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b14:	39 c2                	cmp    %eax,%edx
  800b16:	74 08                	je     800b20 <strnlen+0x1f>
  800b18:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b1c:	75 f3                	jne    800b11 <strnlen+0x10>
  800b1e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	83 c2 01             	add    $0x1,%edx
  800b31:	83 c1 01             	add    $0x1,%ecx
  800b34:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b38:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b3b:	84 db                	test   %bl,%bl
  800b3d:	75 ef                	jne    800b2e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b49:	53                   	push   %ebx
  800b4a:	e8 9a ff ff ff       	call   800ae9 <strlen>
  800b4f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b52:	ff 75 0c             	pushl  0xc(%ebp)
  800b55:	01 d8                	add    %ebx,%eax
  800b57:	50                   	push   %eax
  800b58:	e8 c5 ff ff ff       	call   800b22 <strcpy>
	return dst;
}
  800b5d:	89 d8                	mov    %ebx,%eax
  800b5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	89 f3                	mov    %esi,%ebx
  800b71:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b74:	89 f2                	mov    %esi,%edx
  800b76:	eb 0f                	jmp    800b87 <strncpy+0x23>
		*dst++ = *src;
  800b78:	83 c2 01             	add    $0x1,%edx
  800b7b:	0f b6 01             	movzbl (%ecx),%eax
  800b7e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b81:	80 39 01             	cmpb   $0x1,(%ecx)
  800b84:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b87:	39 da                	cmp    %ebx,%edx
  800b89:	75 ed                	jne    800b78 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b8b:	89 f0                	mov    %esi,%eax
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	8b 75 08             	mov    0x8(%ebp),%esi
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 10             	mov    0x10(%ebp),%edx
  800b9f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ba1:	85 d2                	test   %edx,%edx
  800ba3:	74 21                	je     800bc6 <strlcpy+0x35>
  800ba5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ba9:	89 f2                	mov    %esi,%edx
  800bab:	eb 09                	jmp    800bb6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bad:	83 c2 01             	add    $0x1,%edx
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb6:	39 c2                	cmp    %eax,%edx
  800bb8:	74 09                	je     800bc3 <strlcpy+0x32>
  800bba:	0f b6 19             	movzbl (%ecx),%ebx
  800bbd:	84 db                	test   %bl,%bl
  800bbf:	75 ec                	jne    800bad <strlcpy+0x1c>
  800bc1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bc3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc6:	29 f0                	sub    %esi,%eax
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bd5:	eb 06                	jmp    800bdd <strcmp+0x11>
		p++, q++;
  800bd7:	83 c1 01             	add    $0x1,%ecx
  800bda:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bdd:	0f b6 01             	movzbl (%ecx),%eax
  800be0:	84 c0                	test   %al,%al
  800be2:	74 04                	je     800be8 <strcmp+0x1c>
  800be4:	3a 02                	cmp    (%edx),%al
  800be6:	74 ef                	je     800bd7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800be8:	0f b6 c0             	movzbl %al,%eax
  800beb:	0f b6 12             	movzbl (%edx),%edx
  800bee:	29 d0                	sub    %edx,%eax
}
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	53                   	push   %ebx
  800bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfc:	89 c3                	mov    %eax,%ebx
  800bfe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c01:	eb 06                	jmp    800c09 <strncmp+0x17>
		n--, p++, q++;
  800c03:	83 c0 01             	add    $0x1,%eax
  800c06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c09:	39 d8                	cmp    %ebx,%eax
  800c0b:	74 15                	je     800c22 <strncmp+0x30>
  800c0d:	0f b6 08             	movzbl (%eax),%ecx
  800c10:	84 c9                	test   %cl,%cl
  800c12:	74 04                	je     800c18 <strncmp+0x26>
  800c14:	3a 0a                	cmp    (%edx),%cl
  800c16:	74 eb                	je     800c03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c18:	0f b6 00             	movzbl (%eax),%eax
  800c1b:	0f b6 12             	movzbl (%edx),%edx
  800c1e:	29 d0                	sub    %edx,%eax
  800c20:	eb 05                	jmp    800c27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c34:	eb 07                	jmp    800c3d <strchr+0x13>
		if (*s == c)
  800c36:	38 ca                	cmp    %cl,%dl
  800c38:	74 0f                	je     800c49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c3a:	83 c0 01             	add    $0x1,%eax
  800c3d:	0f b6 10             	movzbl (%eax),%edx
  800c40:	84 d2                	test   %dl,%dl
  800c42:	75 f2                	jne    800c36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c55:	eb 03                	jmp    800c5a <strfind+0xf>
  800c57:	83 c0 01             	add    $0x1,%eax
  800c5a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c5d:	38 ca                	cmp    %cl,%dl
  800c5f:	74 04                	je     800c65 <strfind+0x1a>
  800c61:	84 d2                	test   %dl,%dl
  800c63:	75 f2                	jne    800c57 <strfind+0xc>
			break;
	return (char *) s;
}
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c73:	85 c9                	test   %ecx,%ecx
  800c75:	74 36                	je     800cad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7d:	75 28                	jne    800ca7 <memset+0x40>
  800c7f:	f6 c1 03             	test   $0x3,%cl
  800c82:	75 23                	jne    800ca7 <memset+0x40>
		c &= 0xFF;
  800c84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c88:	89 d3                	mov    %edx,%ebx
  800c8a:	c1 e3 08             	shl    $0x8,%ebx
  800c8d:	89 d6                	mov    %edx,%esi
  800c8f:	c1 e6 18             	shl    $0x18,%esi
  800c92:	89 d0                	mov    %edx,%eax
  800c94:	c1 e0 10             	shl    $0x10,%eax
  800c97:	09 f0                	or     %esi,%eax
  800c99:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c9b:	89 d8                	mov    %ebx,%eax
  800c9d:	09 d0                	or     %edx,%eax
  800c9f:	c1 e9 02             	shr    $0x2,%ecx
  800ca2:	fc                   	cld    
  800ca3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ca5:	eb 06                	jmp    800cad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caa:	fc                   	cld    
  800cab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cad:	89 f8                	mov    %edi,%eax
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cc2:	39 c6                	cmp    %eax,%esi
  800cc4:	73 35                	jae    800cfb <memmove+0x47>
  800cc6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc9:	39 d0                	cmp    %edx,%eax
  800ccb:	73 2e                	jae    800cfb <memmove+0x47>
		s += n;
		d += n;
  800ccd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	09 fe                	or     %edi,%esi
  800cd4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cda:	75 13                	jne    800cef <memmove+0x3b>
  800cdc:	f6 c1 03             	test   $0x3,%cl
  800cdf:	75 0e                	jne    800cef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ce1:	83 ef 04             	sub    $0x4,%edi
  800ce4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ce7:	c1 e9 02             	shr    $0x2,%ecx
  800cea:	fd                   	std    
  800ceb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ced:	eb 09                	jmp    800cf8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cef:	83 ef 01             	sub    $0x1,%edi
  800cf2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cf5:	fd                   	std    
  800cf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cf8:	fc                   	cld    
  800cf9:	eb 1d                	jmp    800d18 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	09 c2                	or     %eax,%edx
  800cff:	f6 c2 03             	test   $0x3,%dl
  800d02:	75 0f                	jne    800d13 <memmove+0x5f>
  800d04:	f6 c1 03             	test   $0x3,%cl
  800d07:	75 0a                	jne    800d13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d09:	c1 e9 02             	shr    $0x2,%ecx
  800d0c:	89 c7                	mov    %eax,%edi
  800d0e:	fc                   	cld    
  800d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d11:	eb 05                	jmp    800d18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d13:	89 c7                	mov    %eax,%edi
  800d15:	fc                   	cld    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d1f:	ff 75 10             	pushl  0x10(%ebp)
  800d22:	ff 75 0c             	pushl  0xc(%ebp)
  800d25:	ff 75 08             	pushl  0x8(%ebp)
  800d28:	e8 87 ff ff ff       	call   800cb4 <memmove>
}
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    

00800d2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3a:	89 c6                	mov    %eax,%esi
  800d3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3f:	eb 1a                	jmp    800d5b <memcmp+0x2c>
		if (*s1 != *s2)
  800d41:	0f b6 08             	movzbl (%eax),%ecx
  800d44:	0f b6 1a             	movzbl (%edx),%ebx
  800d47:	38 d9                	cmp    %bl,%cl
  800d49:	74 0a                	je     800d55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d4b:	0f b6 c1             	movzbl %cl,%eax
  800d4e:	0f b6 db             	movzbl %bl,%ebx
  800d51:	29 d8                	sub    %ebx,%eax
  800d53:	eb 0f                	jmp    800d64 <memcmp+0x35>
		s1++, s2++;
  800d55:	83 c0 01             	add    $0x1,%eax
  800d58:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5b:	39 f0                	cmp    %esi,%eax
  800d5d:	75 e2                	jne    800d41 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	53                   	push   %ebx
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d74:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d78:	eb 0a                	jmp    800d84 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d7a:	0f b6 10             	movzbl (%eax),%edx
  800d7d:	39 da                	cmp    %ebx,%edx
  800d7f:	74 07                	je     800d88 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d81:	83 c0 01             	add    $0x1,%eax
  800d84:	39 c8                	cmp    %ecx,%eax
  800d86:	72 f2                	jb     800d7a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d88:	5b                   	pop    %ebx
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d97:	eb 03                	jmp    800d9c <strtol+0x11>
		s++;
  800d99:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d9c:	0f b6 01             	movzbl (%ecx),%eax
  800d9f:	3c 20                	cmp    $0x20,%al
  800da1:	74 f6                	je     800d99 <strtol+0xe>
  800da3:	3c 09                	cmp    $0x9,%al
  800da5:	74 f2                	je     800d99 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800da7:	3c 2b                	cmp    $0x2b,%al
  800da9:	75 0a                	jne    800db5 <strtol+0x2a>
		s++;
  800dab:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dae:	bf 00 00 00 00       	mov    $0x0,%edi
  800db3:	eb 11                	jmp    800dc6 <strtol+0x3b>
  800db5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dba:	3c 2d                	cmp    $0x2d,%al
  800dbc:	75 08                	jne    800dc6 <strtol+0x3b>
		s++, neg = 1;
  800dbe:	83 c1 01             	add    $0x1,%ecx
  800dc1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dcc:	75 15                	jne    800de3 <strtol+0x58>
  800dce:	80 39 30             	cmpb   $0x30,(%ecx)
  800dd1:	75 10                	jne    800de3 <strtol+0x58>
  800dd3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800dd7:	75 7c                	jne    800e55 <strtol+0xca>
		s += 2, base = 16;
  800dd9:	83 c1 02             	add    $0x2,%ecx
  800ddc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800de1:	eb 16                	jmp    800df9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800de3:	85 db                	test   %ebx,%ebx
  800de5:	75 12                	jne    800df9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800de7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dec:	80 39 30             	cmpb   $0x30,(%ecx)
  800def:	75 08                	jne    800df9 <strtol+0x6e>
		s++, base = 8;
  800df1:	83 c1 01             	add    $0x1,%ecx
  800df4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e01:	0f b6 11             	movzbl (%ecx),%edx
  800e04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e07:	89 f3                	mov    %esi,%ebx
  800e09:	80 fb 09             	cmp    $0x9,%bl
  800e0c:	77 08                	ja     800e16 <strtol+0x8b>
			dig = *s - '0';
  800e0e:	0f be d2             	movsbl %dl,%edx
  800e11:	83 ea 30             	sub    $0x30,%edx
  800e14:	eb 22                	jmp    800e38 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e19:	89 f3                	mov    %esi,%ebx
  800e1b:	80 fb 19             	cmp    $0x19,%bl
  800e1e:	77 08                	ja     800e28 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e20:	0f be d2             	movsbl %dl,%edx
  800e23:	83 ea 57             	sub    $0x57,%edx
  800e26:	eb 10                	jmp    800e38 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e28:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e2b:	89 f3                	mov    %esi,%ebx
  800e2d:	80 fb 19             	cmp    $0x19,%bl
  800e30:	77 16                	ja     800e48 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e32:	0f be d2             	movsbl %dl,%edx
  800e35:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e38:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e3b:	7d 0b                	jge    800e48 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e3d:	83 c1 01             	add    $0x1,%ecx
  800e40:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e44:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e46:	eb b9                	jmp    800e01 <strtol+0x76>

	if (endptr)
  800e48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e4c:	74 0d                	je     800e5b <strtol+0xd0>
		*endptr = (char *) s;
  800e4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e51:	89 0e                	mov    %ecx,(%esi)
  800e53:	eb 06                	jmp    800e5b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e55:	85 db                	test   %ebx,%ebx
  800e57:	74 98                	je     800df1 <strtol+0x66>
  800e59:	eb 9e                	jmp    800df9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e5b:	89 c2                	mov    %eax,%edx
  800e5d:	f7 da                	neg    %edx
  800e5f:	85 ff                	test   %edi,%edi
  800e61:	0f 45 c2             	cmovne %edx,%eax
}
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 c7                	mov    %eax,%edi
  800e7e:	89 c6                	mov    %eax,%esi
  800e80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e82:	5b                   	pop    %ebx
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	57                   	push   %edi
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e92:	b8 01 00 00 00       	mov    $0x1,%eax
  800e97:	89 d1                	mov    %edx,%ecx
  800e99:	89 d3                	mov    %edx,%ebx
  800e9b:	89 d7                	mov    %edx,%edi
  800e9d:	89 d6                	mov    %edx,%esi
  800e9f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb4:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 cb                	mov    %ecx,%ebx
  800ebe:	89 cf                	mov    %ecx,%edi
  800ec0:	89 ce                	mov    %ecx,%esi
  800ec2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7e 17                	jle    800edf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	50                   	push   %eax
  800ecc:	6a 03                	push   $0x3
  800ece:	68 df 2a 80 00       	push   $0x802adf
  800ed3:	6a 23                	push   $0x23
  800ed5:	68 fc 2a 80 00       	push   $0x802afc
  800eda:	e8 dc 13 00 00       	call   8022bb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ef7:	89 d1                	mov    %edx,%ecx
  800ef9:	89 d3                	mov    %edx,%ebx
  800efb:	89 d7                	mov    %edx,%edi
  800efd:	89 d6                	mov    %edx,%esi
  800eff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_yield>:

void
sys_yield(void)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f16:	89 d1                	mov    %edx,%ecx
  800f18:	89 d3                	mov    %edx,%ebx
  800f1a:	89 d7                	mov    %edx,%edi
  800f1c:	89 d6                	mov    %edx,%esi
  800f1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	be 00 00 00 00       	mov    $0x0,%esi
  800f33:	b8 04 00 00 00       	mov    $0x4,%eax
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f41:	89 f7                	mov    %esi,%edi
  800f43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	7e 17                	jle    800f60 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	50                   	push   %eax
  800f4d:	6a 04                	push   $0x4
  800f4f:	68 df 2a 80 00       	push   $0x802adf
  800f54:	6a 23                	push   $0x23
  800f56:	68 fc 2a 80 00       	push   $0x802afc
  800f5b:	e8 5b 13 00 00       	call   8022bb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	57                   	push   %edi
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f71:	b8 05 00 00 00       	mov    $0x5,%eax
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f82:	8b 75 18             	mov    0x18(%ebp),%esi
  800f85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	7e 17                	jle    800fa2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	50                   	push   %eax
  800f8f:	6a 05                	push   $0x5
  800f91:	68 df 2a 80 00       	push   $0x802adf
  800f96:	6a 23                	push   $0x23
  800f98:	68 fc 2a 80 00       	push   $0x802afc
  800f9d:	e8 19 13 00 00       	call   8022bb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	89 df                	mov    %ebx,%edi
  800fc5:	89 de                	mov    %ebx,%esi
  800fc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	7e 17                	jle    800fe4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	50                   	push   %eax
  800fd1:	6a 06                	push   $0x6
  800fd3:	68 df 2a 80 00       	push   $0x802adf
  800fd8:	6a 23                	push   $0x23
  800fda:	68 fc 2a 80 00       	push   $0x802afc
  800fdf:	e8 d7 12 00 00       	call   8022bb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fe4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	57                   	push   %edi
  800ff0:	56                   	push   %esi
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffa:	b8 08 00 00 00       	mov    $0x8,%eax
  800fff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801002:	8b 55 08             	mov    0x8(%ebp),%edx
  801005:	89 df                	mov    %ebx,%edi
  801007:	89 de                	mov    %ebx,%esi
  801009:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100b:	85 c0                	test   %eax,%eax
  80100d:	7e 17                	jle    801026 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	50                   	push   %eax
  801013:	6a 08                	push   $0x8
  801015:	68 df 2a 80 00       	push   $0x802adf
  80101a:	6a 23                	push   $0x23
  80101c:	68 fc 2a 80 00       	push   $0x802afc
  801021:	e8 95 12 00 00       	call   8022bb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801026:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5f                   	pop    %edi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103c:	b8 09 00 00 00       	mov    $0x9,%eax
  801041:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	89 df                	mov    %ebx,%edi
  801049:	89 de                	mov    %ebx,%esi
  80104b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	7e 17                	jle    801068 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	50                   	push   %eax
  801055:	6a 09                	push   $0x9
  801057:	68 df 2a 80 00       	push   $0x802adf
  80105c:	6a 23                	push   $0x23
  80105e:	68 fc 2a 80 00       	push   $0x802afc
  801063:	e8 53 12 00 00       	call   8022bb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801068:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801079:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 df                	mov    %ebx,%edi
  80108b:	89 de                	mov    %ebx,%esi
  80108d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108f:	85 c0                	test   %eax,%eax
  801091:	7e 17                	jle    8010aa <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	6a 0a                	push   $0xa
  801099:	68 df 2a 80 00       	push   $0x802adf
  80109e:	6a 23                	push   $0x23
  8010a0:	68 fc 2a 80 00       	push   $0x802afc
  8010a5:	e8 11 12 00 00       	call   8022bb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b8:	be 00 00 00 00       	mov    $0x0,%esi
  8010bd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ce:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
  8010db:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010eb:	89 cb                	mov    %ecx,%ebx
  8010ed:	89 cf                	mov    %ecx,%edi
  8010ef:	89 ce                	mov    %ecx,%esi
  8010f1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	7e 17                	jle    80110e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	50                   	push   %eax
  8010fb:	6a 0d                	push   $0xd
  8010fd:	68 df 2a 80 00       	push   $0x802adf
  801102:	6a 23                	push   $0x23
  801104:	68 fc 2a 80 00       	push   $0x802afc
  801109:	e8 ad 11 00 00       	call   8022bb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80110e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    

00801116 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111c:	ba 00 00 00 00       	mov    $0x0,%edx
  801121:	b8 0e 00 00 00       	mov    $0xe,%eax
  801126:	89 d1                	mov    %edx,%ecx
  801128:	89 d3                	mov    %edx,%ebx
  80112a:	89 d7                	mov    %edx,%edi
  80112c:	89 d6                	mov    %edx,%esi
  80112e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801143:	b8 0f 00 00 00       	mov    $0xf,%eax
  801148:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114b:	8b 55 08             	mov    0x8(%ebp),%edx
  80114e:	89 df                	mov    %ebx,%edi
  801150:	89 de                	mov    %ebx,%esi
  801152:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801154:	85 c0                	test   %eax,%eax
  801156:	7e 17                	jle    80116f <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	50                   	push   %eax
  80115c:	6a 0f                	push   $0xf
  80115e:	68 df 2a 80 00       	push   $0x802adf
  801163:	6a 23                	push   $0x23
  801165:	68 fc 2a 80 00       	push   $0x802afc
  80116a:	e8 4c 11 00 00       	call   8022bb <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  80116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117a:	8b 45 08             	mov    0x8(%ebp),%eax
  80117d:	05 00 00 00 30       	add    $0x30000000,%eax
  801182:	c1 e8 0c             	shr    $0xc,%eax
}
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80118a:	8b 45 08             	mov    0x8(%ebp),%eax
  80118d:	05 00 00 00 30       	add    $0x30000000,%eax
  801192:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801197:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	c1 ea 16             	shr    $0x16,%edx
  8011ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b5:	f6 c2 01             	test   $0x1,%dl
  8011b8:	74 11                	je     8011cb <fd_alloc+0x2d>
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	c1 ea 0c             	shr    $0xc,%edx
  8011bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c6:	f6 c2 01             	test   $0x1,%dl
  8011c9:	75 09                	jne    8011d4 <fd_alloc+0x36>
			*fd_store = fd;
  8011cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d2:	eb 17                	jmp    8011eb <fd_alloc+0x4d>
  8011d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011de:	75 c9                	jne    8011a9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f3:	83 f8 1f             	cmp    $0x1f,%eax
  8011f6:	77 36                	ja     80122e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f8:	c1 e0 0c             	shl    $0xc,%eax
  8011fb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801200:	89 c2                	mov    %eax,%edx
  801202:	c1 ea 16             	shr    $0x16,%edx
  801205:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120c:	f6 c2 01             	test   $0x1,%dl
  80120f:	74 24                	je     801235 <fd_lookup+0x48>
  801211:	89 c2                	mov    %eax,%edx
  801213:	c1 ea 0c             	shr    $0xc,%edx
  801216:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121d:	f6 c2 01             	test   $0x1,%dl
  801220:	74 1a                	je     80123c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801222:	8b 55 0c             	mov    0xc(%ebp),%edx
  801225:	89 02                	mov    %eax,(%edx)
	return 0;
  801227:	b8 00 00 00 00       	mov    $0x0,%eax
  80122c:	eb 13                	jmp    801241 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801233:	eb 0c                	jmp    801241 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801235:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123a:	eb 05                	jmp    801241 <fd_lookup+0x54>
  80123c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124c:	ba 88 2b 80 00       	mov    $0x802b88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801251:	eb 13                	jmp    801266 <dev_lookup+0x23>
  801253:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801256:	39 08                	cmp    %ecx,(%eax)
  801258:	75 0c                	jne    801266 <dev_lookup+0x23>
			*dev = devtab[i];
  80125a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80125f:	b8 00 00 00 00       	mov    $0x0,%eax
  801264:	eb 2e                	jmp    801294 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801266:	8b 02                	mov    (%edx),%eax
  801268:	85 c0                	test   %eax,%eax
  80126a:	75 e7                	jne    801253 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126c:	a1 18 40 80 00       	mov    0x804018,%eax
  801271:	8b 40 48             	mov    0x48(%eax),%eax
  801274:	83 ec 04             	sub    $0x4,%esp
  801277:	51                   	push   %ecx
  801278:	50                   	push   %eax
  801279:	68 0c 2b 80 00       	push   $0x802b0c
  80127e:	e8 1a f3 ff ff       	call   80059d <cprintf>
	*dev = 0;
  801283:	8b 45 0c             	mov    0xc(%ebp),%eax
  801286:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	56                   	push   %esi
  80129a:	53                   	push   %ebx
  80129b:	83 ec 10             	sub    $0x10,%esp
  80129e:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ae:	c1 e8 0c             	shr    $0xc,%eax
  8012b1:	50                   	push   %eax
  8012b2:	e8 36 ff ff ff       	call   8011ed <fd_lookup>
  8012b7:	83 c4 08             	add    $0x8,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 05                	js     8012c3 <fd_close+0x2d>
	    || fd != fd2)
  8012be:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c1:	74 0c                	je     8012cf <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c3:	84 db                	test   %bl,%bl
  8012c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ca:	0f 44 c2             	cmove  %edx,%eax
  8012cd:	eb 41                	jmp    801310 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	ff 36                	pushl  (%esi)
  8012d8:	e8 66 ff ff ff       	call   801243 <dev_lookup>
  8012dd:	89 c3                	mov    %eax,%ebx
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 1a                	js     801300 <fd_close+0x6a>
		if (dev->dev_close)
  8012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	74 0b                	je     801300 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012f5:	83 ec 0c             	sub    $0xc,%esp
  8012f8:	56                   	push   %esi
  8012f9:	ff d0                	call   *%eax
  8012fb:	89 c3                	mov    %eax,%ebx
  8012fd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	56                   	push   %esi
  801304:	6a 00                	push   $0x0
  801306:	e8 9f fc ff ff       	call   800faa <sys_page_unmap>
	return r;
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	89 d8                	mov    %ebx,%eax
}
  801310:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    

00801317 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	ff 75 08             	pushl  0x8(%ebp)
  801324:	e8 c4 fe ff ff       	call   8011ed <fd_lookup>
  801329:	83 c4 08             	add    $0x8,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 10                	js     801340 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	6a 01                	push   $0x1
  801335:	ff 75 f4             	pushl  -0xc(%ebp)
  801338:	e8 59 ff ff ff       	call   801296 <fd_close>
  80133d:	83 c4 10             	add    $0x10,%esp
}
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <close_all>:

void
close_all(void)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	53                   	push   %ebx
  801346:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801349:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	53                   	push   %ebx
  801352:	e8 c0 ff ff ff       	call   801317 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801357:	83 c3 01             	add    $0x1,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	83 fb 20             	cmp    $0x20,%ebx
  801360:	75 ec                	jne    80134e <close_all+0xc>
		close(i);
}
  801362:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	57                   	push   %edi
  80136b:	56                   	push   %esi
  80136c:	53                   	push   %ebx
  80136d:	83 ec 2c             	sub    $0x2c,%esp
  801370:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801373:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 6e fe ff ff       	call   8011ed <fd_lookup>
  80137f:	83 c4 08             	add    $0x8,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	0f 88 c1 00 00 00    	js     80144b <dup+0xe4>
		return r;
	close(newfdnum);
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	56                   	push   %esi
  80138e:	e8 84 ff ff ff       	call   801317 <close>

	newfd = INDEX2FD(newfdnum);
  801393:	89 f3                	mov    %esi,%ebx
  801395:	c1 e3 0c             	shl    $0xc,%ebx
  801398:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80139e:	83 c4 04             	add    $0x4,%esp
  8013a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a4:	e8 de fd ff ff       	call   801187 <fd2data>
  8013a9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ab:	89 1c 24             	mov    %ebx,(%esp)
  8013ae:	e8 d4 fd ff ff       	call   801187 <fd2data>
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b9:	89 f8                	mov    %edi,%eax
  8013bb:	c1 e8 16             	shr    $0x16,%eax
  8013be:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c5:	a8 01                	test   $0x1,%al
  8013c7:	74 37                	je     801400 <dup+0x99>
  8013c9:	89 f8                	mov    %edi,%eax
  8013cb:	c1 e8 0c             	shr    $0xc,%eax
  8013ce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d5:	f6 c2 01             	test   $0x1,%dl
  8013d8:	74 26                	je     801400 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e9:	50                   	push   %eax
  8013ea:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ed:	6a 00                	push   $0x0
  8013ef:	57                   	push   %edi
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 71 fb ff ff       	call   800f68 <sys_page_map>
  8013f7:	89 c7                	mov    %eax,%edi
  8013f9:	83 c4 20             	add    $0x20,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 2e                	js     80142e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801400:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801403:	89 d0                	mov    %edx,%eax
  801405:	c1 e8 0c             	shr    $0xc,%eax
  801408:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	25 07 0e 00 00       	and    $0xe07,%eax
  801417:	50                   	push   %eax
  801418:	53                   	push   %ebx
  801419:	6a 00                	push   $0x0
  80141b:	52                   	push   %edx
  80141c:	6a 00                	push   $0x0
  80141e:	e8 45 fb ff ff       	call   800f68 <sys_page_map>
  801423:	89 c7                	mov    %eax,%edi
  801425:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801428:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142a:	85 ff                	test   %edi,%edi
  80142c:	79 1d                	jns    80144b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	53                   	push   %ebx
  801432:	6a 00                	push   $0x0
  801434:	e8 71 fb ff ff       	call   800faa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801439:	83 c4 08             	add    $0x8,%esp
  80143c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80143f:	6a 00                	push   $0x0
  801441:	e8 64 fb ff ff       	call   800faa <sys_page_unmap>
	return r;
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	89 f8                	mov    %edi,%eax
}
  80144b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144e:	5b                   	pop    %ebx
  80144f:	5e                   	pop    %esi
  801450:	5f                   	pop    %edi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	53                   	push   %ebx
  801457:	83 ec 14             	sub    $0x14,%esp
  80145a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	53                   	push   %ebx
  801462:	e8 86 fd ff ff       	call   8011ed <fd_lookup>
  801467:	83 c4 08             	add    $0x8,%esp
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 6d                	js     8014dd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147a:	ff 30                	pushl  (%eax)
  80147c:	e8 c2 fd ff ff       	call   801243 <dev_lookup>
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 4c                	js     8014d4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801488:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148b:	8b 42 08             	mov    0x8(%edx),%eax
  80148e:	83 e0 03             	and    $0x3,%eax
  801491:	83 f8 01             	cmp    $0x1,%eax
  801494:	75 21                	jne    8014b7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801496:	a1 18 40 80 00       	mov    0x804018,%eax
  80149b:	8b 40 48             	mov    0x48(%eax),%eax
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	50                   	push   %eax
  8014a3:	68 4d 2b 80 00       	push   $0x802b4d
  8014a8:	e8 f0 f0 ff ff       	call   80059d <cprintf>
		return -E_INVAL;
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b5:	eb 26                	jmp    8014dd <read+0x8a>
	}
	if (!dev->dev_read)
  8014b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ba:	8b 40 08             	mov    0x8(%eax),%eax
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	74 17                	je     8014d8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	ff 75 10             	pushl  0x10(%ebp)
  8014c7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ca:	52                   	push   %edx
  8014cb:	ff d0                	call   *%eax
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	eb 09                	jmp    8014dd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	eb 05                	jmp    8014dd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014dd:	89 d0                	mov    %edx,%eax
  8014df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	57                   	push   %edi
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f8:	eb 21                	jmp    80151b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	89 f0                	mov    %esi,%eax
  8014ff:	29 d8                	sub    %ebx,%eax
  801501:	50                   	push   %eax
  801502:	89 d8                	mov    %ebx,%eax
  801504:	03 45 0c             	add    0xc(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	57                   	push   %edi
  801509:	e8 45 ff ff ff       	call   801453 <read>
		if (m < 0)
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 10                	js     801525 <readn+0x41>
			return m;
		if (m == 0)
  801515:	85 c0                	test   %eax,%eax
  801517:	74 0a                	je     801523 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801519:	01 c3                	add    %eax,%ebx
  80151b:	39 f3                	cmp    %esi,%ebx
  80151d:	72 db                	jb     8014fa <readn+0x16>
  80151f:	89 d8                	mov    %ebx,%eax
  801521:	eb 02                	jmp    801525 <readn+0x41>
  801523:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801525:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 14             	sub    $0x14,%esp
  801534:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801537:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	53                   	push   %ebx
  80153c:	e8 ac fc ff ff       	call   8011ed <fd_lookup>
  801541:	83 c4 08             	add    $0x8,%esp
  801544:	89 c2                	mov    %eax,%edx
  801546:	85 c0                	test   %eax,%eax
  801548:	78 68                	js     8015b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801554:	ff 30                	pushl  (%eax)
  801556:	e8 e8 fc ff ff       	call   801243 <dev_lookup>
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 47                	js     8015a9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801569:	75 21                	jne    80158c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156b:	a1 18 40 80 00       	mov    0x804018,%eax
  801570:	8b 40 48             	mov    0x48(%eax),%eax
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	53                   	push   %ebx
  801577:	50                   	push   %eax
  801578:	68 69 2b 80 00       	push   $0x802b69
  80157d:	e8 1b f0 ff ff       	call   80059d <cprintf>
		return -E_INVAL;
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158a:	eb 26                	jmp    8015b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158f:	8b 52 0c             	mov    0xc(%edx),%edx
  801592:	85 d2                	test   %edx,%edx
  801594:	74 17                	je     8015ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	ff 75 10             	pushl  0x10(%ebp)
  80159c:	ff 75 0c             	pushl  0xc(%ebp)
  80159f:	50                   	push   %eax
  8015a0:	ff d2                	call   *%edx
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	eb 09                	jmp    8015b2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	eb 05                	jmp    8015b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b2:	89 d0                	mov    %edx,%eax
  8015b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	ff 75 08             	pushl  0x8(%ebp)
  8015c6:	e8 22 fc ff ff       	call   8011ed <fd_lookup>
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 0e                	js     8015e0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 14             	sub    $0x14,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	53                   	push   %ebx
  8015f1:	e8 f7 fb ff ff       	call   8011ed <fd_lookup>
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	89 c2                	mov    %eax,%edx
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 65                	js     801664 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801609:	ff 30                	pushl  (%eax)
  80160b:	e8 33 fc ff ff       	call   801243 <dev_lookup>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 44                	js     80165b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161e:	75 21                	jne    801641 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801620:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801625:	8b 40 48             	mov    0x48(%eax),%eax
  801628:	83 ec 04             	sub    $0x4,%esp
  80162b:	53                   	push   %ebx
  80162c:	50                   	push   %eax
  80162d:	68 2c 2b 80 00       	push   $0x802b2c
  801632:	e8 66 ef ff ff       	call   80059d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163f:	eb 23                	jmp    801664 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801641:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801644:	8b 52 18             	mov    0x18(%edx),%edx
  801647:	85 d2                	test   %edx,%edx
  801649:	74 14                	je     80165f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	ff 75 0c             	pushl  0xc(%ebp)
  801651:	50                   	push   %eax
  801652:	ff d2                	call   *%edx
  801654:	89 c2                	mov    %eax,%edx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb 09                	jmp    801664 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	eb 05                	jmp    801664 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80165f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801664:	89 d0                	mov    %edx,%eax
  801666:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	53                   	push   %ebx
  80166f:	83 ec 14             	sub    $0x14,%esp
  801672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801675:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 6c fb ff ff       	call   8011ed <fd_lookup>
  801681:	83 c4 08             	add    $0x8,%esp
  801684:	89 c2                	mov    %eax,%edx
  801686:	85 c0                	test   %eax,%eax
  801688:	78 58                	js     8016e2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801694:	ff 30                	pushl  (%eax)
  801696:	e8 a8 fb ff ff       	call   801243 <dev_lookup>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 37                	js     8016d9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a9:	74 32                	je     8016dd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ab:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ae:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b5:	00 00 00 
	stat->st_isdir = 0;
  8016b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016bf:	00 00 00 
	stat->st_dev = dev;
  8016c2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	53                   	push   %ebx
  8016cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8016cf:	ff 50 14             	call   *0x14(%eax)
  8016d2:	89 c2                	mov    %eax,%edx
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	eb 09                	jmp    8016e2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	eb 05                	jmp    8016e2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e2:	89 d0                	mov    %edx,%eax
  8016e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	56                   	push   %esi
  8016ed:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	6a 00                	push   $0x0
  8016f3:	ff 75 08             	pushl  0x8(%ebp)
  8016f6:	e8 d6 01 00 00       	call   8018d1 <open>
  8016fb:	89 c3                	mov    %eax,%ebx
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	85 c0                	test   %eax,%eax
  801702:	78 1b                	js     80171f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801704:	83 ec 08             	sub    $0x8,%esp
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	50                   	push   %eax
  80170b:	e8 5b ff ff ff       	call   80166b <fstat>
  801710:	89 c6                	mov    %eax,%esi
	close(fd);
  801712:	89 1c 24             	mov    %ebx,(%esp)
  801715:	e8 fd fb ff ff       	call   801317 <close>
	return r;
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	89 f0                	mov    %esi,%eax
}
  80171f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5d                   	pop    %ebp
  801725:	c3                   	ret    

00801726 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	89 c6                	mov    %eax,%esi
  80172d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80172f:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  801736:	75 12                	jne    80174a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801738:	83 ec 0c             	sub    $0xc,%esp
  80173b:	6a 01                	push   $0x1
  80173d:	e8 7a 0c 00 00       	call   8023bc <ipc_find_env>
  801742:	a3 10 40 80 00       	mov    %eax,0x804010
  801747:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174a:	6a 07                	push   $0x7
  80174c:	68 00 50 80 00       	push   $0x805000
  801751:	56                   	push   %esi
  801752:	ff 35 10 40 80 00    	pushl  0x804010
  801758:	e8 0b 0c 00 00       	call   802368 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175d:	83 c4 0c             	add    $0xc,%esp
  801760:	6a 00                	push   $0x0
  801762:	53                   	push   %ebx
  801763:	6a 00                	push   $0x0
  801765:	e8 97 0b 00 00       	call   802301 <ipc_recv>
}
  80176a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	8b 40 0c             	mov    0xc(%eax),%eax
  80177d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801782:	8b 45 0c             	mov    0xc(%ebp),%eax
  801785:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	b8 02 00 00 00       	mov    $0x2,%eax
  801794:	e8 8d ff ff ff       	call   801726 <fsipc>
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b1:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b6:	e8 6b ff ff ff       	call   801726 <fsipc>
}
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 04             	sub    $0x4,%esp
  8017c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8017dc:	e8 45 ff ff ff       	call   801726 <fsipc>
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 2c                	js     801811 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	68 00 50 80 00       	push   $0x805000
  8017ed:	53                   	push   %ebx
  8017ee:	e8 2f f3 ff ff       	call   800b22 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f3:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017fe:	a1 84 50 80 00       	mov    0x805084,%eax
  801803:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801814:	c9                   	leave  
  801815:	c3                   	ret    

00801816 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80181f:	8b 55 08             	mov    0x8(%ebp),%edx
  801822:	8b 52 0c             	mov    0xc(%edx),%edx
  801825:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80182b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801830:	50                   	push   %eax
  801831:	ff 75 0c             	pushl  0xc(%ebp)
  801834:	68 08 50 80 00       	push   $0x805008
  801839:	e8 76 f4 ff ff       	call   800cb4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80183e:	ba 00 00 00 00       	mov    $0x0,%edx
  801843:	b8 04 00 00 00       	mov    $0x4,%eax
  801848:	e8 d9 fe ff ff       	call   801726 <fsipc>

}
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	8b 40 0c             	mov    0xc(%eax),%eax
  80185d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801862:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801868:	ba 00 00 00 00       	mov    $0x0,%edx
  80186d:	b8 03 00 00 00       	mov    $0x3,%eax
  801872:	e8 af fe ff ff       	call   801726 <fsipc>
  801877:	89 c3                	mov    %eax,%ebx
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 4b                	js     8018c8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80187d:	39 c6                	cmp    %eax,%esi
  80187f:	73 16                	jae    801897 <devfile_read+0x48>
  801881:	68 9c 2b 80 00       	push   $0x802b9c
  801886:	68 a3 2b 80 00       	push   $0x802ba3
  80188b:	6a 7c                	push   $0x7c
  80188d:	68 b8 2b 80 00       	push   $0x802bb8
  801892:	e8 24 0a 00 00       	call   8022bb <_panic>
	assert(r <= PGSIZE);
  801897:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80189c:	7e 16                	jle    8018b4 <devfile_read+0x65>
  80189e:	68 c3 2b 80 00       	push   $0x802bc3
  8018a3:	68 a3 2b 80 00       	push   $0x802ba3
  8018a8:	6a 7d                	push   $0x7d
  8018aa:	68 b8 2b 80 00       	push   $0x802bb8
  8018af:	e8 07 0a 00 00       	call   8022bb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018b4:	83 ec 04             	sub    $0x4,%esp
  8018b7:	50                   	push   %eax
  8018b8:	68 00 50 80 00       	push   $0x805000
  8018bd:	ff 75 0c             	pushl  0xc(%ebp)
  8018c0:	e8 ef f3 ff ff       	call   800cb4 <memmove>
	return r;
  8018c5:	83 c4 10             	add    $0x10,%esp
}
  8018c8:	89 d8                	mov    %ebx,%eax
  8018ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cd:	5b                   	pop    %ebx
  8018ce:	5e                   	pop    %esi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    

008018d1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	53                   	push   %ebx
  8018d5:	83 ec 20             	sub    $0x20,%esp
  8018d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018db:	53                   	push   %ebx
  8018dc:	e8 08 f2 ff ff       	call   800ae9 <strlen>
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e9:	7f 67                	jg     801952 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	e8 a7 f8 ff ff       	call   80119e <fd_alloc>
  8018f7:	83 c4 10             	add    $0x10,%esp
		return r;
  8018fa:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 57                	js     801957 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	53                   	push   %ebx
  801904:	68 00 50 80 00       	push   $0x805000
  801909:	e8 14 f2 ff ff       	call   800b22 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80190e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801911:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801916:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801919:	b8 01 00 00 00       	mov    $0x1,%eax
  80191e:	e8 03 fe ff ff       	call   801726 <fsipc>
  801923:	89 c3                	mov    %eax,%ebx
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	85 c0                	test   %eax,%eax
  80192a:	79 14                	jns    801940 <open+0x6f>
		fd_close(fd, 0);
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	6a 00                	push   $0x0
  801931:	ff 75 f4             	pushl  -0xc(%ebp)
  801934:	e8 5d f9 ff ff       	call   801296 <fd_close>
		return r;
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	89 da                	mov    %ebx,%edx
  80193e:	eb 17                	jmp    801957 <open+0x86>
	}

	return fd2num(fd);
  801940:	83 ec 0c             	sub    $0xc,%esp
  801943:	ff 75 f4             	pushl  -0xc(%ebp)
  801946:	e8 2c f8 ff ff       	call   801177 <fd2num>
  80194b:	89 c2                	mov    %eax,%edx
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	eb 05                	jmp    801957 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801952:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801957:	89 d0                	mov    %edx,%eax
  801959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801964:	ba 00 00 00 00       	mov    $0x0,%edx
  801969:	b8 08 00 00 00       	mov    $0x8,%eax
  80196e:	e8 b3 fd ff ff       	call   801726 <fsipc>
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80197b:	68 cf 2b 80 00       	push   $0x802bcf
  801980:	ff 75 0c             	pushl  0xc(%ebp)
  801983:	e8 9a f1 ff ff       	call   800b22 <strcpy>
	return 0;
}
  801988:	b8 00 00 00 00       	mov    $0x0,%eax
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	53                   	push   %ebx
  801993:	83 ec 10             	sub    $0x10,%esp
  801996:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801999:	53                   	push   %ebx
  80199a:	e8 56 0a 00 00       	call   8023f5 <pageref>
  80199f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019a2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019a7:	83 f8 01             	cmp    $0x1,%eax
  8019aa:	75 10                	jne    8019bc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019ac:	83 ec 0c             	sub    $0xc,%esp
  8019af:	ff 73 0c             	pushl  0xc(%ebx)
  8019b2:	e8 c0 02 00 00       	call   801c77 <nsipc_close>
  8019b7:	89 c2                	mov    %eax,%edx
  8019b9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019bc:	89 d0                	mov    %edx,%eax
  8019be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019c9:	6a 00                	push   $0x0
  8019cb:	ff 75 10             	pushl  0x10(%ebp)
  8019ce:	ff 75 0c             	pushl  0xc(%ebp)
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	ff 70 0c             	pushl  0xc(%eax)
  8019d7:	e8 78 03 00 00       	call   801d54 <nsipc_send>
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019e4:	6a 00                	push   $0x0
  8019e6:	ff 75 10             	pushl  0x10(%ebp)
  8019e9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ef:	ff 70 0c             	pushl  0xc(%eax)
  8019f2:	e8 f1 02 00 00       	call   801ce8 <nsipc_recv>
}
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019ff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a02:	52                   	push   %edx
  801a03:	50                   	push   %eax
  801a04:	e8 e4 f7 ff ff       	call   8011ed <fd_lookup>
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	78 17                	js     801a27 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a13:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801a19:	39 08                	cmp    %ecx,(%eax)
  801a1b:	75 05                	jne    801a22 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a20:	eb 05                	jmp    801a27 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a22:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	56                   	push   %esi
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 1c             	sub    $0x1c,%esp
  801a31:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a36:	50                   	push   %eax
  801a37:	e8 62 f7 ff ff       	call   80119e <fd_alloc>
  801a3c:	89 c3                	mov    %eax,%ebx
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 1b                	js     801a60 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a45:	83 ec 04             	sub    $0x4,%esp
  801a48:	68 07 04 00 00       	push   $0x407
  801a4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a50:	6a 00                	push   $0x0
  801a52:	e8 ce f4 ff ff       	call   800f25 <sys_page_alloc>
  801a57:	89 c3                	mov    %eax,%ebx
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	79 10                	jns    801a70 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	56                   	push   %esi
  801a64:	e8 0e 02 00 00       	call   801c77 <nsipc_close>
		return r;
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	89 d8                	mov    %ebx,%eax
  801a6e:	eb 24                	jmp    801a94 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a70:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a79:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a85:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	50                   	push   %eax
  801a8c:	e8 e6 f6 ff ff       	call   801177 <fd2num>
  801a91:	83 c4 10             	add    $0x10,%esp
}
  801a94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa4:	e8 50 ff ff ff       	call   8019f9 <fd2sockid>
		return r;
  801aa9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 1f                	js     801ace <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aaf:	83 ec 04             	sub    $0x4,%esp
  801ab2:	ff 75 10             	pushl  0x10(%ebp)
  801ab5:	ff 75 0c             	pushl  0xc(%ebp)
  801ab8:	50                   	push   %eax
  801ab9:	e8 12 01 00 00       	call   801bd0 <nsipc_accept>
  801abe:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 07                	js     801ace <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ac7:	e8 5d ff ff ff       	call   801a29 <alloc_sockfd>
  801acc:	89 c1                	mov    %eax,%ecx
}
  801ace:	89 c8                	mov    %ecx,%eax
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  801adb:	e8 19 ff ff ff       	call   8019f9 <fd2sockid>
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	78 12                	js     801af6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	ff 75 10             	pushl  0x10(%ebp)
  801aea:	ff 75 0c             	pushl  0xc(%ebp)
  801aed:	50                   	push   %eax
  801aee:	e8 2d 01 00 00       	call   801c20 <nsipc_bind>
  801af3:	83 c4 10             	add    $0x10,%esp
}
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <shutdown>:

int
shutdown(int s, int how)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	e8 f3 fe ff ff       	call   8019f9 <fd2sockid>
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 0f                	js     801b19 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b0a:	83 ec 08             	sub    $0x8,%esp
  801b0d:	ff 75 0c             	pushl  0xc(%ebp)
  801b10:	50                   	push   %eax
  801b11:	e8 3f 01 00 00       	call   801c55 <nsipc_shutdown>
  801b16:	83 c4 10             	add    $0x10,%esp
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b21:	8b 45 08             	mov    0x8(%ebp),%eax
  801b24:	e8 d0 fe ff ff       	call   8019f9 <fd2sockid>
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 12                	js     801b3f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b2d:	83 ec 04             	sub    $0x4,%esp
  801b30:	ff 75 10             	pushl  0x10(%ebp)
  801b33:	ff 75 0c             	pushl  0xc(%ebp)
  801b36:	50                   	push   %eax
  801b37:	e8 55 01 00 00       	call   801c91 <nsipc_connect>
  801b3c:	83 c4 10             	add    $0x10,%esp
}
  801b3f:	c9                   	leave  
  801b40:	c3                   	ret    

00801b41 <listen>:

int
listen(int s, int backlog)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b47:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4a:	e8 aa fe ff ff       	call   8019f9 <fd2sockid>
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	78 0f                	js     801b62 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b53:	83 ec 08             	sub    $0x8,%esp
  801b56:	ff 75 0c             	pushl  0xc(%ebp)
  801b59:	50                   	push   %eax
  801b5a:	e8 67 01 00 00       	call   801cc6 <nsipc_listen>
  801b5f:	83 c4 10             	add    $0x10,%esp
}
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b6a:	ff 75 10             	pushl  0x10(%ebp)
  801b6d:	ff 75 0c             	pushl  0xc(%ebp)
  801b70:	ff 75 08             	pushl  0x8(%ebp)
  801b73:	e8 3a 02 00 00       	call   801db2 <nsipc_socket>
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 05                	js     801b84 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b7f:	e8 a5 fe ff ff       	call   801a29 <alloc_sockfd>
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 04             	sub    $0x4,%esp
  801b8d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b8f:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801b96:	75 12                	jne    801baa <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b98:	83 ec 0c             	sub    $0xc,%esp
  801b9b:	6a 02                	push   $0x2
  801b9d:	e8 1a 08 00 00       	call   8023bc <ipc_find_env>
  801ba2:	a3 14 40 80 00       	mov    %eax,0x804014
  801ba7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801baa:	6a 07                	push   $0x7
  801bac:	68 00 60 80 00       	push   $0x806000
  801bb1:	53                   	push   %ebx
  801bb2:	ff 35 14 40 80 00    	pushl  0x804014
  801bb8:	e8 ab 07 00 00       	call   802368 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bbd:	83 c4 0c             	add    $0xc,%esp
  801bc0:	6a 00                	push   $0x0
  801bc2:	6a 00                	push   $0x0
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 36 07 00 00       	call   802301 <ipc_recv>
}
  801bcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801be0:	8b 06                	mov    (%esi),%eax
  801be2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801be7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bec:	e8 95 ff ff ff       	call   801b86 <nsipc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	78 20                	js     801c17 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bf7:	83 ec 04             	sub    $0x4,%esp
  801bfa:	ff 35 10 60 80 00    	pushl  0x806010
  801c00:	68 00 60 80 00       	push   $0x806000
  801c05:	ff 75 0c             	pushl  0xc(%ebp)
  801c08:	e8 a7 f0 ff ff       	call   800cb4 <memmove>
		*addrlen = ret->ret_addrlen;
  801c0d:	a1 10 60 80 00       	mov    0x806010,%eax
  801c12:	89 06                	mov    %eax,(%esi)
  801c14:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c17:	89 d8                	mov    %ebx,%eax
  801c19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	53                   	push   %ebx
  801c24:	83 ec 08             	sub    $0x8,%esp
  801c27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c32:	53                   	push   %ebx
  801c33:	ff 75 0c             	pushl  0xc(%ebp)
  801c36:	68 04 60 80 00       	push   $0x806004
  801c3b:	e8 74 f0 ff ff       	call   800cb4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c40:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c46:	b8 02 00 00 00       	mov    $0x2,%eax
  801c4b:	e8 36 ff ff ff       	call   801b86 <nsipc>
}
  801c50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    

00801c55 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c66:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c6b:	b8 03 00 00 00       	mov    $0x3,%eax
  801c70:	e8 11 ff ff ff       	call   801b86 <nsipc>
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <nsipc_close>:

int
nsipc_close(int s)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c85:	b8 04 00 00 00       	mov    $0x4,%eax
  801c8a:	e8 f7 fe ff ff       	call   801b86 <nsipc>
}
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	53                   	push   %ebx
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ca3:	53                   	push   %ebx
  801ca4:	ff 75 0c             	pushl  0xc(%ebp)
  801ca7:	68 04 60 80 00       	push   $0x806004
  801cac:	e8 03 f0 ff ff       	call   800cb4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cb1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cb7:	b8 05 00 00 00       	mov    $0x5,%eax
  801cbc:	e8 c5 fe ff ff       	call   801b86 <nsipc>
}
  801cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cdc:	b8 06 00 00 00       	mov    $0x6,%eax
  801ce1:	e8 a0 fe ff ff       	call   801b86 <nsipc>
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	56                   	push   %esi
  801cec:	53                   	push   %ebx
  801ced:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cf8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cfe:	8b 45 14             	mov    0x14(%ebp),%eax
  801d01:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d06:	b8 07 00 00 00       	mov    $0x7,%eax
  801d0b:	e8 76 fe ff ff       	call   801b86 <nsipc>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	85 c0                	test   %eax,%eax
  801d14:	78 35                	js     801d4b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d16:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d1b:	7f 04                	jg     801d21 <nsipc_recv+0x39>
  801d1d:	39 c6                	cmp    %eax,%esi
  801d1f:	7d 16                	jge    801d37 <nsipc_recv+0x4f>
  801d21:	68 db 2b 80 00       	push   $0x802bdb
  801d26:	68 a3 2b 80 00       	push   $0x802ba3
  801d2b:	6a 62                	push   $0x62
  801d2d:	68 f0 2b 80 00       	push   $0x802bf0
  801d32:	e8 84 05 00 00       	call   8022bb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d37:	83 ec 04             	sub    $0x4,%esp
  801d3a:	50                   	push   %eax
  801d3b:	68 00 60 80 00       	push   $0x806000
  801d40:	ff 75 0c             	pushl  0xc(%ebp)
  801d43:	e8 6c ef ff ff       	call   800cb4 <memmove>
  801d48:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5e                   	pop    %esi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	53                   	push   %ebx
  801d58:	83 ec 04             	sub    $0x4,%esp
  801d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d61:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d66:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d6c:	7e 16                	jle    801d84 <nsipc_send+0x30>
  801d6e:	68 fc 2b 80 00       	push   $0x802bfc
  801d73:	68 a3 2b 80 00       	push   $0x802ba3
  801d78:	6a 6d                	push   $0x6d
  801d7a:	68 f0 2b 80 00       	push   $0x802bf0
  801d7f:	e8 37 05 00 00       	call   8022bb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d84:	83 ec 04             	sub    $0x4,%esp
  801d87:	53                   	push   %ebx
  801d88:	ff 75 0c             	pushl  0xc(%ebp)
  801d8b:	68 0c 60 80 00       	push   $0x80600c
  801d90:	e8 1f ef ff ff       	call   800cb4 <memmove>
	nsipcbuf.send.req_size = size;
  801d95:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d9e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801da3:	b8 08 00 00 00       	mov    $0x8,%eax
  801da8:	e8 d9 fd ff ff       	call   801b86 <nsipc>
}
  801dad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    

00801db2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801dcb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dd0:	b8 09 00 00 00       	mov    $0x9,%eax
  801dd5:	e8 ac fd ff ff       	call   801b86 <nsipc>
}
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
  801de1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801de4:	83 ec 0c             	sub    $0xc,%esp
  801de7:	ff 75 08             	pushl  0x8(%ebp)
  801dea:	e8 98 f3 ff ff       	call   801187 <fd2data>
  801def:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801df1:	83 c4 08             	add    $0x8,%esp
  801df4:	68 08 2c 80 00       	push   $0x802c08
  801df9:	53                   	push   %ebx
  801dfa:	e8 23 ed ff ff       	call   800b22 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dff:	8b 46 04             	mov    0x4(%esi),%eax
  801e02:	2b 06                	sub    (%esi),%eax
  801e04:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e0a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e11:	00 00 00 
	stat->st_dev = &devpipe;
  801e14:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801e1b:	30 80 00 
	return 0;
}
  801e1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e26:	5b                   	pop    %ebx
  801e27:	5e                   	pop    %esi
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	53                   	push   %ebx
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e34:	53                   	push   %ebx
  801e35:	6a 00                	push   $0x0
  801e37:	e8 6e f1 ff ff       	call   800faa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e3c:	89 1c 24             	mov    %ebx,(%esp)
  801e3f:	e8 43 f3 ff ff       	call   801187 <fd2data>
  801e44:	83 c4 08             	add    $0x8,%esp
  801e47:	50                   	push   %eax
  801e48:	6a 00                	push   $0x0
  801e4a:	e8 5b f1 ff ff       	call   800faa <sys_page_unmap>
}
  801e4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	57                   	push   %edi
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
  801e5a:	83 ec 1c             	sub    $0x1c,%esp
  801e5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e60:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e62:	a1 18 40 80 00       	mov    0x804018,%eax
  801e67:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e6a:	83 ec 0c             	sub    $0xc,%esp
  801e6d:	ff 75 e0             	pushl  -0x20(%ebp)
  801e70:	e8 80 05 00 00       	call   8023f5 <pageref>
  801e75:	89 c3                	mov    %eax,%ebx
  801e77:	89 3c 24             	mov    %edi,(%esp)
  801e7a:	e8 76 05 00 00       	call   8023f5 <pageref>
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	39 c3                	cmp    %eax,%ebx
  801e84:	0f 94 c1             	sete   %cl
  801e87:	0f b6 c9             	movzbl %cl,%ecx
  801e8a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e8d:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801e93:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e96:	39 ce                	cmp    %ecx,%esi
  801e98:	74 1b                	je     801eb5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e9a:	39 c3                	cmp    %eax,%ebx
  801e9c:	75 c4                	jne    801e62 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e9e:	8b 42 58             	mov    0x58(%edx),%eax
  801ea1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ea4:	50                   	push   %eax
  801ea5:	56                   	push   %esi
  801ea6:	68 0f 2c 80 00       	push   $0x802c0f
  801eab:	e8 ed e6 ff ff       	call   80059d <cprintf>
  801eb0:	83 c4 10             	add    $0x10,%esp
  801eb3:	eb ad                	jmp    801e62 <_pipeisclosed+0xe>
	}
}
  801eb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5f                   	pop    %edi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    

00801ec0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	57                   	push   %edi
  801ec4:	56                   	push   %esi
  801ec5:	53                   	push   %ebx
  801ec6:	83 ec 28             	sub    $0x28,%esp
  801ec9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ecc:	56                   	push   %esi
  801ecd:	e8 b5 f2 ff ff       	call   801187 <fd2data>
  801ed2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	bf 00 00 00 00       	mov    $0x0,%edi
  801edc:	eb 4b                	jmp    801f29 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ede:	89 da                	mov    %ebx,%edx
  801ee0:	89 f0                	mov    %esi,%eax
  801ee2:	e8 6d ff ff ff       	call   801e54 <_pipeisclosed>
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	75 48                	jne    801f33 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801eeb:	e8 16 f0 ff ff       	call   800f06 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ef0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ef3:	8b 0b                	mov    (%ebx),%ecx
  801ef5:	8d 51 20             	lea    0x20(%ecx),%edx
  801ef8:	39 d0                	cmp    %edx,%eax
  801efa:	73 e2                	jae    801ede <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801eff:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f03:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f06:	89 c2                	mov    %eax,%edx
  801f08:	c1 fa 1f             	sar    $0x1f,%edx
  801f0b:	89 d1                	mov    %edx,%ecx
  801f0d:	c1 e9 1b             	shr    $0x1b,%ecx
  801f10:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f13:	83 e2 1f             	and    $0x1f,%edx
  801f16:	29 ca                	sub    %ecx,%edx
  801f18:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f1c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f20:	83 c0 01             	add    $0x1,%eax
  801f23:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f26:	83 c7 01             	add    $0x1,%edi
  801f29:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f2c:	75 c2                	jne    801ef0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f2e:	8b 45 10             	mov    0x10(%ebp),%eax
  801f31:	eb 05                	jmp    801f38 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3b:	5b                   	pop    %ebx
  801f3c:	5e                   	pop    %esi
  801f3d:	5f                   	pop    %edi
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    

00801f40 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	57                   	push   %edi
  801f44:	56                   	push   %esi
  801f45:	53                   	push   %ebx
  801f46:	83 ec 18             	sub    $0x18,%esp
  801f49:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f4c:	57                   	push   %edi
  801f4d:	e8 35 f2 ff ff       	call   801187 <fd2data>
  801f52:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f5c:	eb 3d                	jmp    801f9b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f5e:	85 db                	test   %ebx,%ebx
  801f60:	74 04                	je     801f66 <devpipe_read+0x26>
				return i;
  801f62:	89 d8                	mov    %ebx,%eax
  801f64:	eb 44                	jmp    801faa <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f66:	89 f2                	mov    %esi,%edx
  801f68:	89 f8                	mov    %edi,%eax
  801f6a:	e8 e5 fe ff ff       	call   801e54 <_pipeisclosed>
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	75 32                	jne    801fa5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f73:	e8 8e ef ff ff       	call   800f06 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f78:	8b 06                	mov    (%esi),%eax
  801f7a:	3b 46 04             	cmp    0x4(%esi),%eax
  801f7d:	74 df                	je     801f5e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f7f:	99                   	cltd   
  801f80:	c1 ea 1b             	shr    $0x1b,%edx
  801f83:	01 d0                	add    %edx,%eax
  801f85:	83 e0 1f             	and    $0x1f,%eax
  801f88:	29 d0                	sub    %edx,%eax
  801f8a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f92:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f95:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f98:	83 c3 01             	add    $0x1,%ebx
  801f9b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f9e:	75 d8                	jne    801f78 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fa0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa3:	eb 05                	jmp    801faa <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    

00801fb2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	56                   	push   %esi
  801fb6:	53                   	push   %ebx
  801fb7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	e8 db f1 ff ff       	call   80119e <fd_alloc>
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	89 c2                	mov    %eax,%edx
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	0f 88 2c 01 00 00    	js     8020fc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd0:	83 ec 04             	sub    $0x4,%esp
  801fd3:	68 07 04 00 00       	push   $0x407
  801fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 43 ef ff ff       	call   800f25 <sys_page_alloc>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	89 c2                	mov    %eax,%edx
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	0f 88 0d 01 00 00    	js     8020fc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ff5:	50                   	push   %eax
  801ff6:	e8 a3 f1 ff ff       	call   80119e <fd_alloc>
  801ffb:	89 c3                	mov    %eax,%ebx
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	85 c0                	test   %eax,%eax
  802002:	0f 88 e2 00 00 00    	js     8020ea <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802008:	83 ec 04             	sub    $0x4,%esp
  80200b:	68 07 04 00 00       	push   $0x407
  802010:	ff 75 f0             	pushl  -0x10(%ebp)
  802013:	6a 00                	push   $0x0
  802015:	e8 0b ef ff ff       	call   800f25 <sys_page_alloc>
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	85 c0                	test   %eax,%eax
  802021:	0f 88 c3 00 00 00    	js     8020ea <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802027:	83 ec 0c             	sub    $0xc,%esp
  80202a:	ff 75 f4             	pushl  -0xc(%ebp)
  80202d:	e8 55 f1 ff ff       	call   801187 <fd2data>
  802032:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802034:	83 c4 0c             	add    $0xc,%esp
  802037:	68 07 04 00 00       	push   $0x407
  80203c:	50                   	push   %eax
  80203d:	6a 00                	push   $0x0
  80203f:	e8 e1 ee ff ff       	call   800f25 <sys_page_alloc>
  802044:	89 c3                	mov    %eax,%ebx
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	0f 88 89 00 00 00    	js     8020da <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802051:	83 ec 0c             	sub    $0xc,%esp
  802054:	ff 75 f0             	pushl  -0x10(%ebp)
  802057:	e8 2b f1 ff ff       	call   801187 <fd2data>
  80205c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802063:	50                   	push   %eax
  802064:	6a 00                	push   $0x0
  802066:	56                   	push   %esi
  802067:	6a 00                	push   $0x0
  802069:	e8 fa ee ff ff       	call   800f68 <sys_page_map>
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	83 c4 20             	add    $0x20,%esp
  802073:	85 c0                	test   %eax,%eax
  802075:	78 55                	js     8020cc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802077:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80207d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802080:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802085:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80208c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802092:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802095:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802097:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80209a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020a1:	83 ec 0c             	sub    $0xc,%esp
  8020a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a7:	e8 cb f0 ff ff       	call   801177 <fd2num>
  8020ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020af:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020b1:	83 c4 04             	add    $0x4,%esp
  8020b4:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b7:	e8 bb f0 ff ff       	call   801177 <fd2num>
  8020bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020bf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020c2:	83 c4 10             	add    $0x10,%esp
  8020c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8020ca:	eb 30                	jmp    8020fc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020cc:	83 ec 08             	sub    $0x8,%esp
  8020cf:	56                   	push   %esi
  8020d0:	6a 00                	push   $0x0
  8020d2:	e8 d3 ee ff ff       	call   800faa <sys_page_unmap>
  8020d7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020da:	83 ec 08             	sub    $0x8,%esp
  8020dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8020e0:	6a 00                	push   $0x0
  8020e2:	e8 c3 ee ff ff       	call   800faa <sys_page_unmap>
  8020e7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020ea:	83 ec 08             	sub    $0x8,%esp
  8020ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f0:	6a 00                	push   $0x0
  8020f2:	e8 b3 ee ff ff       	call   800faa <sys_page_unmap>
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020fc:	89 d0                	mov    %edx,%eax
  8020fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80210b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210e:	50                   	push   %eax
  80210f:	ff 75 08             	pushl  0x8(%ebp)
  802112:	e8 d6 f0 ff ff       	call   8011ed <fd_lookup>
  802117:	83 c4 10             	add    $0x10,%esp
  80211a:	85 c0                	test   %eax,%eax
  80211c:	78 18                	js     802136 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	ff 75 f4             	pushl  -0xc(%ebp)
  802124:	e8 5e f0 ff ff       	call   801187 <fd2data>
	return _pipeisclosed(fd, p);
  802129:	89 c2                	mov    %eax,%edx
  80212b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212e:	e8 21 fd ff ff       	call   801e54 <_pipeisclosed>
  802133:	83 c4 10             	add    $0x10,%esp
}
  802136:	c9                   	leave  
  802137:	c3                   	ret    

00802138 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    

00802142 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802148:	68 27 2c 80 00       	push   $0x802c27
  80214d:	ff 75 0c             	pushl  0xc(%ebp)
  802150:	e8 cd e9 ff ff       	call   800b22 <strcpy>
	return 0;
}
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
  80215a:	c9                   	leave  
  80215b:	c3                   	ret    

0080215c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	57                   	push   %edi
  802160:	56                   	push   %esi
  802161:	53                   	push   %ebx
  802162:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802168:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80216d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802173:	eb 2d                	jmp    8021a2 <devcons_write+0x46>
		m = n - tot;
  802175:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802178:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80217a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80217d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802182:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802185:	83 ec 04             	sub    $0x4,%esp
  802188:	53                   	push   %ebx
  802189:	03 45 0c             	add    0xc(%ebp),%eax
  80218c:	50                   	push   %eax
  80218d:	57                   	push   %edi
  80218e:	e8 21 eb ff ff       	call   800cb4 <memmove>
		sys_cputs(buf, m);
  802193:	83 c4 08             	add    $0x8,%esp
  802196:	53                   	push   %ebx
  802197:	57                   	push   %edi
  802198:	e8 cc ec ff ff       	call   800e69 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80219d:	01 de                	add    %ebx,%esi
  80219f:	83 c4 10             	add    $0x10,%esp
  8021a2:	89 f0                	mov    %esi,%eax
  8021a4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021a7:	72 cc                	jb     802175 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ac:	5b                   	pop    %ebx
  8021ad:	5e                   	pop    %esi
  8021ae:	5f                   	pop    %edi
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	83 ec 08             	sub    $0x8,%esp
  8021b7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021c0:	74 2a                	je     8021ec <devcons_read+0x3b>
  8021c2:	eb 05                	jmp    8021c9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021c4:	e8 3d ed ff ff       	call   800f06 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021c9:	e8 b9 ec ff ff       	call   800e87 <sys_cgetc>
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	74 f2                	je     8021c4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021d2:	85 c0                	test   %eax,%eax
  8021d4:	78 16                	js     8021ec <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021d6:	83 f8 04             	cmp    $0x4,%eax
  8021d9:	74 0c                	je     8021e7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021de:	88 02                	mov    %al,(%edx)
	return 1;
  8021e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e5:	eb 05                	jmp    8021ec <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021e7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021ec:	c9                   	leave  
  8021ed:	c3                   	ret    

008021ee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021ee:	55                   	push   %ebp
  8021ef:	89 e5                	mov    %esp,%ebp
  8021f1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021fa:	6a 01                	push   $0x1
  8021fc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ff:	50                   	push   %eax
  802200:	e8 64 ec ff ff       	call   800e69 <sys_cputs>
}
  802205:	83 c4 10             	add    $0x10,%esp
  802208:	c9                   	leave  
  802209:	c3                   	ret    

0080220a <getchar>:

int
getchar(void)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802210:	6a 01                	push   $0x1
  802212:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802215:	50                   	push   %eax
  802216:	6a 00                	push   $0x0
  802218:	e8 36 f2 ff ff       	call   801453 <read>
	if (r < 0)
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	85 c0                	test   %eax,%eax
  802222:	78 0f                	js     802233 <getchar+0x29>
		return r;
	if (r < 1)
  802224:	85 c0                	test   %eax,%eax
  802226:	7e 06                	jle    80222e <getchar+0x24>
		return -E_EOF;
	return c;
  802228:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80222c:	eb 05                	jmp    802233 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80222e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    

00802235 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80223b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80223e:	50                   	push   %eax
  80223f:	ff 75 08             	pushl  0x8(%ebp)
  802242:	e8 a6 ef ff ff       	call   8011ed <fd_lookup>
  802247:	83 c4 10             	add    $0x10,%esp
  80224a:	85 c0                	test   %eax,%eax
  80224c:	78 11                	js     80225f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80224e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802251:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802257:	39 10                	cmp    %edx,(%eax)
  802259:	0f 94 c0             	sete   %al
  80225c:	0f b6 c0             	movzbl %al,%eax
}
  80225f:	c9                   	leave  
  802260:	c3                   	ret    

00802261 <opencons>:

int
opencons(void)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226a:	50                   	push   %eax
  80226b:	e8 2e ef ff ff       	call   80119e <fd_alloc>
  802270:	83 c4 10             	add    $0x10,%esp
		return r;
  802273:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802275:	85 c0                	test   %eax,%eax
  802277:	78 3e                	js     8022b7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802279:	83 ec 04             	sub    $0x4,%esp
  80227c:	68 07 04 00 00       	push   $0x407
  802281:	ff 75 f4             	pushl  -0xc(%ebp)
  802284:	6a 00                	push   $0x0
  802286:	e8 9a ec ff ff       	call   800f25 <sys_page_alloc>
  80228b:	83 c4 10             	add    $0x10,%esp
		return r;
  80228e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802290:	85 c0                	test   %eax,%eax
  802292:	78 23                	js     8022b7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802294:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80229f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022a9:	83 ec 0c             	sub    $0xc,%esp
  8022ac:	50                   	push   %eax
  8022ad:	e8 c5 ee ff ff       	call   801177 <fd2num>
  8022b2:	89 c2                	mov    %eax,%edx
  8022b4:	83 c4 10             	add    $0x10,%esp
}
  8022b7:	89 d0                	mov    %edx,%eax
  8022b9:	c9                   	leave  
  8022ba:	c3                   	ret    

008022bb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	56                   	push   %esi
  8022bf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022c0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022c3:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8022c9:	e8 19 ec ff ff       	call   800ee7 <sys_getenvid>
  8022ce:	83 ec 0c             	sub    $0xc,%esp
  8022d1:	ff 75 0c             	pushl  0xc(%ebp)
  8022d4:	ff 75 08             	pushl  0x8(%ebp)
  8022d7:	56                   	push   %esi
  8022d8:	50                   	push   %eax
  8022d9:	68 34 2c 80 00       	push   $0x802c34
  8022de:	e8 ba e2 ff ff       	call   80059d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022e3:	83 c4 18             	add    $0x18,%esp
  8022e6:	53                   	push   %ebx
  8022e7:	ff 75 10             	pushl  0x10(%ebp)
  8022ea:	e8 5d e2 ff ff       	call   80054c <vcprintf>
	cprintf("\n");
  8022ef:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  8022f6:	e8 a2 e2 ff ff       	call   80059d <cprintf>
  8022fb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022fe:	cc                   	int3   
  8022ff:	eb fd                	jmp    8022fe <_panic+0x43>

00802301 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	56                   	push   %esi
  802305:	53                   	push   %ebx
  802306:	8b 75 08             	mov    0x8(%ebp),%esi
  802309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  80230f:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  802311:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802316:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802319:	83 ec 0c             	sub    $0xc,%esp
  80231c:	50                   	push   %eax
  80231d:	e8 b3 ed ff ff       	call   8010d5 <sys_ipc_recv>

	if (from_env_store != NULL)
  802322:	83 c4 10             	add    $0x10,%esp
  802325:	85 f6                	test   %esi,%esi
  802327:	74 14                	je     80233d <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802329:	ba 00 00 00 00       	mov    $0x0,%edx
  80232e:	85 c0                	test   %eax,%eax
  802330:	78 09                	js     80233b <ipc_recv+0x3a>
  802332:	8b 15 18 40 80 00    	mov    0x804018,%edx
  802338:	8b 52 74             	mov    0x74(%edx),%edx
  80233b:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80233d:	85 db                	test   %ebx,%ebx
  80233f:	74 14                	je     802355 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  802341:	ba 00 00 00 00       	mov    $0x0,%edx
  802346:	85 c0                	test   %eax,%eax
  802348:	78 09                	js     802353 <ipc_recv+0x52>
  80234a:	8b 15 18 40 80 00    	mov    0x804018,%edx
  802350:	8b 52 78             	mov    0x78(%edx),%edx
  802353:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  802355:	85 c0                	test   %eax,%eax
  802357:	78 08                	js     802361 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  802359:	a1 18 40 80 00       	mov    0x804018,%eax
  80235e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802361:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    

00802368 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802368:	55                   	push   %ebp
  802369:	89 e5                	mov    %esp,%ebp
  80236b:	57                   	push   %edi
  80236c:	56                   	push   %esi
  80236d:	53                   	push   %ebx
  80236e:	83 ec 0c             	sub    $0xc,%esp
  802371:	8b 7d 08             	mov    0x8(%ebp),%edi
  802374:	8b 75 0c             	mov    0xc(%ebp),%esi
  802377:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  80237a:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80237c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802381:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  802384:	ff 75 14             	pushl  0x14(%ebp)
  802387:	53                   	push   %ebx
  802388:	56                   	push   %esi
  802389:	57                   	push   %edi
  80238a:	e8 23 ed ff ff       	call   8010b2 <sys_ipc_try_send>

		if (err < 0) {
  80238f:	83 c4 10             	add    $0x10,%esp
  802392:	85 c0                	test   %eax,%eax
  802394:	79 1e                	jns    8023b4 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  802396:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802399:	75 07                	jne    8023a2 <ipc_send+0x3a>
				sys_yield();
  80239b:	e8 66 eb ff ff       	call   800f06 <sys_yield>
  8023a0:	eb e2                	jmp    802384 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8023a2:	50                   	push   %eax
  8023a3:	68 58 2c 80 00       	push   $0x802c58
  8023a8:	6a 49                	push   $0x49
  8023aa:	68 65 2c 80 00       	push   $0x802c65
  8023af:	e8 07 ff ff ff       	call   8022bb <_panic>
		}

	} while (err < 0);

}
  8023b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    

008023bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023bc:	55                   	push   %ebp
  8023bd:	89 e5                	mov    %esp,%ebp
  8023bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023c7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023d0:	8b 52 50             	mov    0x50(%edx),%edx
  8023d3:	39 ca                	cmp    %ecx,%edx
  8023d5:	75 0d                	jne    8023e4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8023d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023df:	8b 40 48             	mov    0x48(%eax),%eax
  8023e2:	eb 0f                	jmp    8023f3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023e4:	83 c0 01             	add    $0x1,%eax
  8023e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023ec:	75 d9                	jne    8023c7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    

008023f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023f5:	55                   	push   %ebp
  8023f6:	89 e5                	mov    %esp,%ebp
  8023f8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023fb:	89 d0                	mov    %edx,%eax
  8023fd:	c1 e8 16             	shr    $0x16,%eax
  802400:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802407:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80240c:	f6 c1 01             	test   $0x1,%cl
  80240f:	74 1d                	je     80242e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802411:	c1 ea 0c             	shr    $0xc,%edx
  802414:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80241b:	f6 c2 01             	test   $0x1,%dl
  80241e:	74 0e                	je     80242e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802420:	c1 ea 0c             	shr    $0xc,%edx
  802423:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80242a:	ef 
  80242b:	0f b7 c0             	movzwl %ax,%eax
}
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    

00802430 <__udivdi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80243b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80243f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 f6                	test   %esi,%esi
  802449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80244d:	89 ca                	mov    %ecx,%edx
  80244f:	89 f8                	mov    %edi,%eax
  802451:	75 3d                	jne    802490 <__udivdi3+0x60>
  802453:	39 cf                	cmp    %ecx,%edi
  802455:	0f 87 c5 00 00 00    	ja     802520 <__udivdi3+0xf0>
  80245b:	85 ff                	test   %edi,%edi
  80245d:	89 fd                	mov    %edi,%ebp
  80245f:	75 0b                	jne    80246c <__udivdi3+0x3c>
  802461:	b8 01 00 00 00       	mov    $0x1,%eax
  802466:	31 d2                	xor    %edx,%edx
  802468:	f7 f7                	div    %edi
  80246a:	89 c5                	mov    %eax,%ebp
  80246c:	89 c8                	mov    %ecx,%eax
  80246e:	31 d2                	xor    %edx,%edx
  802470:	f7 f5                	div    %ebp
  802472:	89 c1                	mov    %eax,%ecx
  802474:	89 d8                	mov    %ebx,%eax
  802476:	89 cf                	mov    %ecx,%edi
  802478:	f7 f5                	div    %ebp
  80247a:	89 c3                	mov    %eax,%ebx
  80247c:	89 d8                	mov    %ebx,%eax
  80247e:	89 fa                	mov    %edi,%edx
  802480:	83 c4 1c             	add    $0x1c,%esp
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	90                   	nop
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	39 ce                	cmp    %ecx,%esi
  802492:	77 74                	ja     802508 <__udivdi3+0xd8>
  802494:	0f bd fe             	bsr    %esi,%edi
  802497:	83 f7 1f             	xor    $0x1f,%edi
  80249a:	0f 84 98 00 00 00    	je     802538 <__udivdi3+0x108>
  8024a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	89 c5                	mov    %eax,%ebp
  8024a9:	29 fb                	sub    %edi,%ebx
  8024ab:	d3 e6                	shl    %cl,%esi
  8024ad:	89 d9                	mov    %ebx,%ecx
  8024af:	d3 ed                	shr    %cl,%ebp
  8024b1:	89 f9                	mov    %edi,%ecx
  8024b3:	d3 e0                	shl    %cl,%eax
  8024b5:	09 ee                	or     %ebp,%esi
  8024b7:	89 d9                	mov    %ebx,%ecx
  8024b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024bd:	89 d5                	mov    %edx,%ebp
  8024bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024c3:	d3 ed                	shr    %cl,%ebp
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e2                	shl    %cl,%edx
  8024c9:	89 d9                	mov    %ebx,%ecx
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	09 c2                	or     %eax,%edx
  8024cf:	89 d0                	mov    %edx,%eax
  8024d1:	89 ea                	mov    %ebp,%edx
  8024d3:	f7 f6                	div    %esi
  8024d5:	89 d5                	mov    %edx,%ebp
  8024d7:	89 c3                	mov    %eax,%ebx
  8024d9:	f7 64 24 0c          	mull   0xc(%esp)
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	72 10                	jb     8024f1 <__udivdi3+0xc1>
  8024e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e6                	shl    %cl,%esi
  8024e9:	39 c6                	cmp    %eax,%esi
  8024eb:	73 07                	jae    8024f4 <__udivdi3+0xc4>
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	75 03                	jne    8024f4 <__udivdi3+0xc4>
  8024f1:	83 eb 01             	sub    $0x1,%ebx
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 d8                	mov    %ebx,%eax
  8024f8:	89 fa                	mov    %edi,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	31 ff                	xor    %edi,%edi
  80250a:	31 db                	xor    %ebx,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d8                	mov    %ebx,%eax
  802522:	f7 f7                	div    %edi
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 c3                	mov    %eax,%ebx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 fa                	mov    %edi,%edx
  80252c:	83 c4 1c             	add    $0x1c,%esp
  80252f:	5b                   	pop    %ebx
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    
  802534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802538:	39 ce                	cmp    %ecx,%esi
  80253a:	72 0c                	jb     802548 <__udivdi3+0x118>
  80253c:	31 db                	xor    %ebx,%ebx
  80253e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802542:	0f 87 34 ff ff ff    	ja     80247c <__udivdi3+0x4c>
  802548:	bb 01 00 00 00       	mov    $0x1,%ebx
  80254d:	e9 2a ff ff ff       	jmp    80247c <__udivdi3+0x4c>
  802552:	66 90                	xchg   %ax,%ax
  802554:	66 90                	xchg   %ax,%ax
  802556:	66 90                	xchg   %ax,%ax
  802558:	66 90                	xchg   %ax,%ax
  80255a:	66 90                	xchg   %ax,%ax
  80255c:	66 90                	xchg   %ax,%ax
  80255e:	66 90                	xchg   %ax,%ax

00802560 <__umoddi3>:
  802560:	55                   	push   %ebp
  802561:	57                   	push   %edi
  802562:	56                   	push   %esi
  802563:	53                   	push   %ebx
  802564:	83 ec 1c             	sub    $0x1c,%esp
  802567:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80256b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80256f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802573:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802577:	85 d2                	test   %edx,%edx
  802579:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80257d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802581:	89 f3                	mov    %esi,%ebx
  802583:	89 3c 24             	mov    %edi,(%esp)
  802586:	89 74 24 04          	mov    %esi,0x4(%esp)
  80258a:	75 1c                	jne    8025a8 <__umoddi3+0x48>
  80258c:	39 f7                	cmp    %esi,%edi
  80258e:	76 50                	jbe    8025e0 <__umoddi3+0x80>
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	f7 f7                	div    %edi
  802596:	89 d0                	mov    %edx,%eax
  802598:	31 d2                	xor    %edx,%edx
  80259a:	83 c4 1c             	add    $0x1c,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	39 f2                	cmp    %esi,%edx
  8025aa:	89 d0                	mov    %edx,%eax
  8025ac:	77 52                	ja     802600 <__umoddi3+0xa0>
  8025ae:	0f bd ea             	bsr    %edx,%ebp
  8025b1:	83 f5 1f             	xor    $0x1f,%ebp
  8025b4:	75 5a                	jne    802610 <__umoddi3+0xb0>
  8025b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ba:	0f 82 e0 00 00 00    	jb     8026a0 <__umoddi3+0x140>
  8025c0:	39 0c 24             	cmp    %ecx,(%esp)
  8025c3:	0f 86 d7 00 00 00    	jbe    8026a0 <__umoddi3+0x140>
  8025c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025d1:	83 c4 1c             	add    $0x1c,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	85 ff                	test   %edi,%edi
  8025e2:	89 fd                	mov    %edi,%ebp
  8025e4:	75 0b                	jne    8025f1 <__umoddi3+0x91>
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	f7 f7                	div    %edi
  8025ef:	89 c5                	mov    %eax,%ebp
  8025f1:	89 f0                	mov    %esi,%eax
  8025f3:	31 d2                	xor    %edx,%edx
  8025f5:	f7 f5                	div    %ebp
  8025f7:	89 c8                	mov    %ecx,%eax
  8025f9:	f7 f5                	div    %ebp
  8025fb:	89 d0                	mov    %edx,%eax
  8025fd:	eb 99                	jmp    802598 <__umoddi3+0x38>
  8025ff:	90                   	nop
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	83 c4 1c             	add    $0x1c,%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5f                   	pop    %edi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    
  80260c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802610:	8b 34 24             	mov    (%esp),%esi
  802613:	bf 20 00 00 00       	mov    $0x20,%edi
  802618:	89 e9                	mov    %ebp,%ecx
  80261a:	29 ef                	sub    %ebp,%edi
  80261c:	d3 e0                	shl    %cl,%eax
  80261e:	89 f9                	mov    %edi,%ecx
  802620:	89 f2                	mov    %esi,%edx
  802622:	d3 ea                	shr    %cl,%edx
  802624:	89 e9                	mov    %ebp,%ecx
  802626:	09 c2                	or     %eax,%edx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 14 24             	mov    %edx,(%esp)
  80262d:	89 f2                	mov    %esi,%edx
  80262f:	d3 e2                	shl    %cl,%edx
  802631:	89 f9                	mov    %edi,%ecx
  802633:	89 54 24 04          	mov    %edx,0x4(%esp)
  802637:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80263b:	d3 e8                	shr    %cl,%eax
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	89 c6                	mov    %eax,%esi
  802641:	d3 e3                	shl    %cl,%ebx
  802643:	89 f9                	mov    %edi,%ecx
  802645:	89 d0                	mov    %edx,%eax
  802647:	d3 e8                	shr    %cl,%eax
  802649:	89 e9                	mov    %ebp,%ecx
  80264b:	09 d8                	or     %ebx,%eax
  80264d:	89 d3                	mov    %edx,%ebx
  80264f:	89 f2                	mov    %esi,%edx
  802651:	f7 34 24             	divl   (%esp)
  802654:	89 d6                	mov    %edx,%esi
  802656:	d3 e3                	shl    %cl,%ebx
  802658:	f7 64 24 04          	mull   0x4(%esp)
  80265c:	39 d6                	cmp    %edx,%esi
  80265e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802662:	89 d1                	mov    %edx,%ecx
  802664:	89 c3                	mov    %eax,%ebx
  802666:	72 08                	jb     802670 <__umoddi3+0x110>
  802668:	75 11                	jne    80267b <__umoddi3+0x11b>
  80266a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80266e:	73 0b                	jae    80267b <__umoddi3+0x11b>
  802670:	2b 44 24 04          	sub    0x4(%esp),%eax
  802674:	1b 14 24             	sbb    (%esp),%edx
  802677:	89 d1                	mov    %edx,%ecx
  802679:	89 c3                	mov    %eax,%ebx
  80267b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80267f:	29 da                	sub    %ebx,%edx
  802681:	19 ce                	sbb    %ecx,%esi
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 f0                	mov    %esi,%eax
  802687:	d3 e0                	shl    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	d3 ea                	shr    %cl,%edx
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	d3 ee                	shr    %cl,%esi
  802691:	09 d0                	or     %edx,%eax
  802693:	89 f2                	mov    %esi,%edx
  802695:	83 c4 1c             	add    $0x1c,%esp
  802698:	5b                   	pop    %ebx
  802699:	5e                   	pop    %esi
  80269a:	5f                   	pop    %edi
  80269b:	5d                   	pop    %ebp
  80269c:	c3                   	ret    
  80269d:	8d 76 00             	lea    0x0(%esi),%esi
  8026a0:	29 f9                	sub    %edi,%ecx
  8026a2:	19 d6                	sbb    %edx,%esi
  8026a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ac:	e9 18 ff ff ff       	jmp    8025c9 <__umoddi3+0x69>
